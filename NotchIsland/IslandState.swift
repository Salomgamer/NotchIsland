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

    @Published var mode: IslandMode = .media
    @Published var size: IslandSize = .compact

    @Published var title: String = "No Music Playing"
    @Published var subtitle: String = "Play Spotify or Music"
    @Published var progress: Double = 0.0
    @Published var remainingSeconds: Double = 1500
    @Published var totalSeconds: Double = 1500
    @Published var batteryPercentage: Int = 100
    @Published var isCharging: Bool = false

    private var timerCancellable: AnyCancellable?
    private var nowPlayingCancellables = Set<AnyCancellable>()
    private var batteryTimer: Timer?

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
        self.mode = .media
        self.size = .compact

        // Enable battery monitoring immediately for real-time accuracy
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBatteryState()

        // Observe battery notifications
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBatteryState()
        }

        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBatteryState()
        }

        // Fast timer for real-time battery & state sync
        batteryTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateBatteryState()
            self?.syncModeState()
        }

        // Observe real Spotify / EeveeSpotify now playing updates
        let np = NowPlayingService.shared
        np.$title.receive(on: DispatchQueue.main).sink { [weak self] newTitle in
            if self?.mode == .media {
                self?.title = newTitle
            }
        }.store(in: &nowPlayingCancellables)

        np.$artist.receive(on: DispatchQueue.main).sink { [weak self] newArtist in
            if self?.mode == .media {
                self?.subtitle = newArtist
            }
        }.store(in: &nowPlayingCancellables)

        setMode(.media)
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
            let np = NowPlayingService.shared
            title = np.title
            subtitle = np.artist
            progress = 0.5

        case .battery:
            updateBatteryState()
            title = "iPhone 11"
            subtitle = isCharging ? "Charging • \(batteryPercentage)%" : "\(batteryPercentage)% Remaining"
            progress = Double(batteryPercentage) / 100.0
        }
    }

    private func updateBatteryState() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let rawLevel = UIDevice.current.batteryLevel
        if rawLevel >= 0 {
            // Precise 1% rounding
            self.batteryPercentage = Int(round(rawLevel * 100.0))
        }

        let state = UIDevice.current.batteryState
        self.isCharging = (state == .charging || state == .full)

        if mode == .battery {
            self.title = "iPhone 11"
            self.subtitle = isCharging ? "Charging • \(batteryPercentage)%" : "\(batteryPercentage)% Remaining"
            self.progress = Double(batteryPercentage) / 100.0
        }
    }

    private func syncModeState() {
        if mode == .media {
            let np = NowPlayingService.shared
            if self.title != np.title { self.title = np.title }
            if self.subtitle != np.artist { self.subtitle = np.artist }
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
