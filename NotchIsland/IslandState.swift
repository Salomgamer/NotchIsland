import SwiftUI
import Combine

enum IslandMode: String, CaseIterable {
    case timer = "Timer"
    case media = "Music"
    case battery = "Status"
}

class IslandState: ObservableObject {
    static let shared = IslandState()

    @Published var mode: IslandMode = .timer
    @Published var title: String = "Focus Session"
    @Published var subtitle: String = "25:00 remaining"
    @Published var iconName: String = "timer"
    @Published var progress: Double = 0.0
    @Published var accentColor: Color = .orange

    // Internal timer tracking
    private var timerCancellable: AnyCancellable?
    private var totalSeconds: Double = 1500 // 25 mins
    private var remainingSeconds: Double = 1500

    init() {
        setMode(.timer)
    }

    func setMode(_ newMode: IslandMode) {
        self.mode = newMode
        timerCancellable?.cancel()

        switch newMode {
        case .timer:
            title = "Focus Session"
            subtitle = "25:00 remaining"
            iconName = "timer"
            accentColor = .orange
            progress = 0.0
            startDemoTimer()

        case .media:
            title = "Starboy"
            subtitle = "The Weeknd"
            iconName = "waveform"
            accentColor = .green
            progress = 0.42

        case .battery:
            UIDevice.current.isBatteryMonitoringEnabled = true
            let level = UIDevice.current.batteryLevel
            let batteryPct = level >= 0 ? Int(level * 100) : 100
            let isCharging = UIDevice.current.batteryState == .charging || UIDevice.current.batteryState == .full

            title = "iPhone 11"
            subtitle = isCharging ? "Charging • \(batteryPct)%" : "\(batteryPct)% Remaining"
            iconName = isCharging ? "bolt.fill" : "battery.75"
            accentColor = isCharging ? .green : .cyan
            progress = Double(batteryPct) / 100.0
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
                    let mins = Int(self.remainingSeconds) / 60
                    let secs = Int(self.remainingSeconds) % 60
                    self.subtitle = String(format: "%02d:%02d remaining", mins, secs)
                    self.progress = (self.totalSeconds - self.remainingSeconds) / self.totalSeconds
                }
            }
    }
}
