import SwiftUI
import Combine

enum IslandMode: String, CaseIterable {
    case timer = "Timer"
    case media = "Music"
    case battery = "Battery"
}

enum IslandSize: String, CaseIterable {
    case slim = "Slim (160×46)"
    case compact = "Compact (180×52)"
    case expanded = "Expanded (210×58)"
}

class IslandState: ObservableObject {
    static let shared = IslandState()

    @Published var mode: IslandMode = .timer
    @Published var size: IslandSize = .compact

    @Published var title: String = "Focus Session"
    @Published var subtitle: String = "25:00 remaining"
    @Published var progress: Double = 0.0
    @Published var remainingSeconds: Double = 1500
    @Published var totalSeconds: Double = 1500
    @Published var batteryPercentage: Int = 88
    @Published var isCharging: Bool = true

    private var timerCancellable: AnyCancellable?

    var islandWidth: CGFloat {
        switch size {
        case .slim: return 160
        case .compact: return 180
        case .expanded: return 210
        }
    }

    var islandHeight: CGFloat {
        switch size {
        case .slim: return 46
        case .compact: return 52
        case .expanded: return 58
        }
    }

    var timerFormatted: String {
        let mins = Int(remainingSeconds) / 60
        let secs = Int(remainingSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    init() {
        self.mode = .timer
        self.size = .compact
        self.title = "Focus Session"
        self.subtitle = "25:00 remaining"
        self.remainingSeconds = 1500
        self.totalSeconds = 1500
        self.progress = 0.0
        startDemoTimer()
    }

    func setSize(_ newSize: IslandSize) {
        self.size = newSize
    }

    func setMode(_ newMode: IslandMode) {
        self.mode = newMode
        timerCancellable?.cancel()

        switch newMode {
        case .timer:
            title = "Focus Session"
            subtitle = "\(timerFormatted) remaining"
            startDemoTimer()

        case .media:
            title = "Starboy"
            subtitle = "The Weeknd"
            progress = 0.45

        case .battery:
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            batteryPercentage = level >= 0 ? Int(level * 100) : 88
            isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
            title = "iPhone 11"
            subtitle = isCharging ? "Fast Charging • \(batteryPercentage)%" : "\(batteryPercentage)% Remaining"
            progress = Double(batteryPercentage) / 100.0
        }
    }

    private func startDemoTimer() {
        totalSeconds = 1500
        remainingSeconds = 1500
        progress = 0.0

        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                    self.subtitle = "\(self.timerFormatted) remaining"
                    self.progress = (self.totalSeconds - self.remainingSeconds) / self.totalSeconds
                }
            }
    }
}
