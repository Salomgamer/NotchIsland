import SwiftUI
import Combine

enum IslandMode: String, CaseIterable {
    case media = "Music"
    case call = "Call HUD"
    case timer = "Timer"
    case stopwatch = "Stopwatch"
    case battery = "Battery"
    case silent = "Silent HUD"
}

enum IslandSize: String, CaseIterable {
    case slim = "Slim (160×46)"
    case compact = "Compact (180×52)"
    case expanded = "Expanded (210×64)"
}

enum AccentTheme: String, CaseIterable {
    case spotifyGreen = "Spotify Green"
    case appleOrange = "Apple Orange"
    case cyberCyan = "Cyber Cyan"
    case electricPurple = "Electric Purple"
    case crimsonRed = "Crimson Red"

    var color: Color {
        switch self {
        case .spotifyGreen: return Color(red: 0.18, green: 0.84, blue: 0.38)
        case .appleOrange: return Color(red: 1.0, green: 0.58, blue: 0.0)
        case .cyberCyan: return Color(red: 0.0, green: 0.94, blue: 1.0)
        case .electricPurple: return Color(red: 0.68, green: 0.32, blue: 0.95)
        case .crimsonRed: return Color(red: 1.0, green: 0.18, blue: 0.33)
        }
    }
}

class IslandState: ObservableObject {
    static let shared = IslandState()

    @Published var mode: IslandMode = .media
    @Published var size: IslandSize = .compact
    @Published var theme: AccentTheme = .spotifyGreen
    @Published var isExpanded: Bool = false

    // MARK: - Media State
    @Published var mediaTitle: String = "No Music Playing"
    @Published var mediaArtist: String = "Play track in Spotify"
    @Published var mediaProgress: Double = 0.45
    @Published var isMediaPlaying: Bool = false

    // MARK: - Call HUD State
    @Published var callerName: String = "Incoming Call"
    @Published var callerSubtitle: String = "Mobile • iPhone"
    @Published var callDuration: Int = 0
    @Published var isCallActive: Bool = false

    // MARK: - Timer State
    @Published var remainingSeconds: Double = 1500
    @Published var totalSeconds: Double = 1500
    @Published var isTimerRunning: Bool = true

    // MARK: - Stopwatch State
    @Published var stopwatchSeconds: Double = 0.0
    @Published var isStopwatchRunning: Bool = false

    // MARK: - Battery State
    @Published var batteryPercentage: Int = 100
    @Published var isCharging: Bool = false

    // MARK: - Silent HUD State
    @Published var isSilentOn: Bool = true

    private var timerCancellable: AnyCancellable?
    private var stopwatchCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    var islandWidth: CGFloat {
        if isExpanded { return 230 }
        switch size {
        case .slim: return 160
        case .compact: return 180
        case .expanded: return 210
        }
    }

    var islandHeight: CGFloat {
        if isExpanded { return 72 }
        switch size {
        case .slim: return 46
        case .compact: return 52
        case .expanded: return 64
        }
    }

    var timerFormatted: String {
        let mins = Int(remainingSeconds) / 60
        let secs = Int(remainingSeconds) % 60
        return String(format: "%d:%02d", mins, secs)
    }

    var stopwatchFormatted: String {
        let mins = Int(stopwatchSeconds) / 60
        let secs = Int(stopwatchSeconds) % 60
        let ms = Int((stopwatchSeconds.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", mins, secs, ms)
    }

    init() {
        self.mode = .media
        self.size = .compact
        self.theme = .spotifyGreen

        // 1. Bind exact hardware battery
        let bs = BatteryService.shared
        self.batteryPercentage = bs.percentage
        self.isCharging = bs.isCharging

        bs.$percentage.receive(on: DispatchQueue.main).sink { [weak self] newPct in
            self?.batteryPercentage = newPct
        }.store(in: &cancellables)

        bs.$isCharging.receive(on: DispatchQueue.main).sink { [weak self] charging in
            self?.isCharging = charging
        }.store(in: &cancellables)

        // 2. Bind live Now Playing
        let np = NowPlayingService.shared
        np.$title.receive(on: DispatchQueue.main).sink { [weak self] newTitle in
            self?.mediaTitle = newTitle
        }.store(in: &cancellables)

        np.$artist.receive(on: DispatchQueue.main).sink { [weak self] newArtist in
            self?.mediaArtist = newArtist
        }.store(in: &cancellables)

        np.$isPlaying.receive(on: DispatchQueue.main).sink { [weak self] playing in
            self?.isMediaPlaying = playing
        }.store(in: &cancellables)

        startTimer()
    }

    func setMode(_ newMode: IslandMode) {
        self.mode = newMode
        switch newMode {
        case .media:
            break
        case .call:
            callDuration = 0
            isCallActive = false
        case .timer:
            startTimer()
        case .stopwatch:
            startStopwatch()
        case .battery:
            BatteryService.shared.updateBattery()
        case .silent:
            break
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func setSize(_ newSize: IslandSize) {
        self.size = newSize
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func toggleExpanded() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
            self.isExpanded.toggle()
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    // MARK: - Timer Logic
    func startTimer() {
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isTimerRunning else { return }
                if self.remainingSeconds > 0 {
                    self.remainingSeconds -= 1
                }
            }
    }

    func setTimerPreset(minutes: Int) {
        totalSeconds = Double(minutes * 60)
        remainingSeconds = totalSeconds
        isTimerRunning = true
        startTimer()
    }

    // MARK: - Stopwatch Logic
    func startStopwatch() {
        stopwatchCancellable?.cancel()
        isStopwatchRunning = true
        stopwatchCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isStopwatchRunning else { return }
                self.stopwatchSeconds += 0.05
            }
    }

    func resetStopwatch() {
        stopwatchCancellable?.cancel()
        stopwatchSeconds = 0.0
        isStopwatchRunning = false
    }

    // MARK: - Call HUD Logic
    func answerCall() {
        withAnimation {
            isCallActive = true
            callerName = "Connected Call"
            callerSubtitle = "00:01"
        }
    }

    func declineCall() {
        withAnimation {
            isCallActive = false
            callerName = "Call Ended"
            callerSubtitle = "Dismissed"
        }
    }
}
