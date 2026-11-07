import SwiftUI
import Combine

enum IslandMode: String, CaseIterable {
    case timer = "Timer"
    case media = "Music"
    case battery = "Battery"
}

enum IslandSize: String, CaseIterable {
    case mini = "Ultra-Slim (130×28)"
    case compact = "Compact (148×32)"
    case standard = "Standard (184×34)"
}

class IslandState: ObservableObject {
    static let shared = IslandState()

    @Published var mode: IslandMode = .timer
    @Published var size: IslandSize = .compact

    @Published var title: String = "Focus"
    @Published var subtitle: String = "25:00"
    @Published var centerText: String = "Focus"
    @Published var progress: Double = 0.0
    @Published var remainingSeconds: Double = 1500
    @Published var totalSeconds: Double = 1500
    @Published var batteryPercentage: Int = 88
    @Published var isCharging: Bool = true

    private var timerCancellable: AnyCancellable?

    var islandWidth: CGFloat {
        switch size {
        case .mini: return 130
        case .compact: return 148
        case .standard: return 184
        }
    }

    var islandHeight: CGFloat {
        switch size {
        case .mini: return 28
        case .compact: return 32
        case .standard: return 34
        }
    }

    var showCenterText: Bool {
        return size != .mini
    }

    var timerFormatted: String {
        let mins = Int(remainingSeconds) / 60
        let secs = Int(remainingSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    init() {
        // Completely safe initial values without triggering external singletons
        self.mode = .timer
        self.size = .compact
        self.centerText = "Focus"
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
            centerText = size == .standard ? "Focus Session" : "Focus"
            startDemoTimer()

        case .media:
            centerText = "Starboy"

        case .battery:
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            batteryPercentage = level >= 0 ? Int(level * 100) : 88
            isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full
            centerText = isCharging ? "Charging" : "Battery"
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
                    self.progress = (self.totalSeconds - self.remainingSeconds) / self.totalSeconds
                }
            }
    }
}
