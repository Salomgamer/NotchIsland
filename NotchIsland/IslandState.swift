import SwiftUI
import Combine
import AudioToolbox
import AVFoundation

enum IslandMode: String, CaseIterable {
    case media = "Music & Battery"
    case call = "Call HUD"
    case timer = "Timer"
    case stopwatch = "Stopwatch"
    case battery = "Battery"
    case silent = "Silent HUD"
}

enum IslandSize: String, CaseIterable {
    case slim = "Slim (144×32)"
    case compact = "Compact (156×36)"
    case expanded = "Expanded (216×68)"
}

enum DeviceNotchPreset: String, CaseIterable, Identifiable {
    case iphone11 = "iPhone 11 / XR"
    case iphone12 = "iPhone 12 / 12 Pro"
    case iphone13 = "iPhone 13 / 14"
    case custom = "Custom Notch"

    var id: String { rawValue }

    var dimensions: (width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        switch self {
        case .iphone11:
            return (width: 156, height: 36, cornerRadius: 18)
        case .iphone12:
            return (width: 150, height: 35, cornerRadius: 17.5)
        case .iphone13:
            return (width: 138, height: 34, cornerRadius: 17)
        case .custom:
            return (width: 156, height: 36, cornerRadius: 18)
        }
    }

    var badge: String {
        switch self {
        case .iphone11: return "156×36"
        case .iphone12: return "150×35"
        case .iphone13: return "138×34"
        case .custom: return "Custom"
        }
    }
}

enum IslandBackgroundStyle: String, CaseIterable, Identifiable {
    case oledBlack = "OLED Black"
    case frostedGlass = "Frosted Glass"
    case artworkAdaptive = "Artwork Adaptive"
    case midnightNavy = "Midnight Navy"
    case darkObsidian = "Dark Obsidian"
    case deepCrimson = "Deep Crimson"
    case cyberNeon = "Cyber Neon"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .oledBlack: return "circle.fill"
        case .frostedGlass: return "aqi.medium"
        case .artworkAdaptive: return "wand.and.stars"
        case .midnightNavy: return "moon.stars.fill"
        case .darkObsidian: return "shield.fill"
        case .deepCrimson: return "flame.fill"
        case .cyberNeon: return "bolt.fill"
        }
    }
}

enum DoubleTapAction: String, CaseIterable, Identifiable {
    case playPause = "Play / Pause"
    case nextTrack = "Next Track"
    case toggleTorch = "Toggle Torch"
    case toggleSilent = "Toggle Silent"
    case expandCollapse = "Expand / Collapse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .playPause: return "playpause.fill"
        case .nextTrack: return "forward.fill"
        case .toggleTorch: return "flashlight.on.fill"
        case .toggleSilent: return "bell.slash.fill"
        case .expandCollapse: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
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
    @Published var isMultipurpose: Bool = true

    // MARK: - Background Customization
    @Published var backgroundStyle: IslandBackgroundStyle = .oledBlack
    @Published var backgroundOpacity: Double = 1.0

    // MARK: - Double-Tap Action
    @Published var doubleTapAction: DoubleTapAction = .playPause

    // MARK: - Custom Size Calibration & Presets
    @Published var selectedPreset: DeviceNotchPreset = .iphone11
    @Published var useCustomSize: Bool = false
    @Published var customWidth: CGFloat = 156
    @Published var customHeight: CGFloat = 36
    @Published var customCornerRadius: CGFloat = 18

    // MARK: - Notification Banner State
    @Published var activeNotificationTitle: String = ""
    @Published var activeNotificationSubtitle: String = ""
    @Published var activeNotificationIcon: String = "bell.badge.fill"
    @Published var activeNotificationColor: Color? = nil
    @Published var isShowingNotification: Bool = false
    private var notificationDismissWorkItem: DispatchWorkItem?

    // MARK: - Volume HUD State
    @Published var systemVolume: Float = 0.5
    @Published var isShowingVolumeHUD: Bool = false
    private var volumeHUDDismissItem: DispatchWorkItem?

    // MARK: - Media State
    @Published var mediaTitle: String = "No Music Playing"
    @Published var mediaArtist: String = "Play Spotify, YouTube, Safari, or Stremio"
    @Published var mediaProgress: Double = 0.45
    @Published var isMediaPlaying: Bool = false

    // MARK: - Call HUD State
    @Published var callerName: String = "Incoming Call"
    @Published var callerSubtitle: String = "Mobile • iPhone"
    @Published var callDuration: Int = 0
    @Published var isCallActive: Bool = false
    @Published var isCallMuted: Bool = false
    @Published var isSpeakerOn: Bool = false
    private var callTimer: AnyCancellable?

    // MARK: - Timer State
    @Published var remainingSeconds: Double = 1500
    @Published var totalSeconds: Double = 1500
    @Published var isTimerRunning: Bool = true

    // MARK: - Stopwatch State
    @Published var stopwatchSeconds: Double = 0.0
    @Published var isStopwatchRunning: Bool = false
    @Published var stopwatchLaps: [String] = []

    // MARK: - Battery State
    @Published var batteryPercentage: Int = 100
    @Published var isCharging: Bool = false
    private var previousBatteryLevel: Int = 100

    // MARK: - Silent HUD State
    @Published var isSilentOn: Bool = true

    private var timerCancellable: AnyCancellable?
    private var stopwatchCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    var islandWidth: CGFloat {
        if isExpanded { return 216 }
        if useCustomSize { return customWidth }
        switch size {
        case .slim: return 144
        case .compact: return 156
        case .expanded: return 186
        }
    }

    var islandHeight: CGFloat {
        if isExpanded { return 68 }
        if useCustomSize { return customHeight }
        switch size {
        case .slim: return 32
        case .compact: return 36
        case .expanded: return 48
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
        self.isMultipurpose = true

        // 1. Bind exact hardware battery
        let bs = BatteryService.shared
        self.batteryPercentage = bs.percentage
        self.previousBatteryLevel = bs.percentage
        self.isCharging = bs.isCharging

        bs.$percentage.receive(on: DispatchQueue.main).sink { [weak self] newPct in
            guard let self = self else { return }
            let prev = self.previousBatteryLevel
            self.batteryPercentage = newPct
            self.previousBatteryLevel = newPct

            // Low battery alert trigger at 20%
            if prev > 20 && newPct <= 20 && !self.isCharging {
                self.triggerNotification(
                    title: "Low Battery",
                    subtitle: "\(newPct)% • Connect Charger",
                    icon: "battery.25",
                    color: .red
                )
            }
        }.store(in: &cancellables)

        var initialChargingState: Bool? = nil
        bs.$isCharging.receive(on: DispatchQueue.main).sink { [weak self] charging in
            guard let self = self else { return }
            let wasCharging = self.isCharging
            self.isCharging = charging

            if initialChargingState == nil {
                initialChargingState = charging
                return
            }

            if !wasCharging && charging {
                self.triggerNotification(
                    title: "Charging Started",
                    subtitle: "\(self.batteryPercentage)% • Fast Charging",
                    icon: "bolt.fill",
                    color: .green
                )
            }
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

        setupVolumeObserver()
        startTimer()
    }

    private func setupVolumeObserver() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            self.systemVolume = AVAudioSession.sharedInstance().outputVolume
        } catch {
            print("Audio session error: \(error)")
        }

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AVSystemController_SystemVolumeDidChangeNotification"),
            object: nil,
            queue: .main
        ) { [weak self] notif in
            guard let self = self else { return }
            if let userInfo = notif.userInfo,
               let vol = userInfo["AVSystemController_AudioVolumeNotificationParameter"] as? Float {
                self.showVolumeHUD(level: vol)
            } else {
                let vol = AVAudioSession.sharedInstance().outputVolume
                self.showVolumeHUD(level: vol)
            }
        }
    }

    func showVolumeHUD(level: Float) {
        self.systemVolume = level
        self.volumeHUDDismissItem?.cancel()
        HapticService.shared.light()

        withAnimation(.spring(response: 0.32, dampingFraction: 0.75)) {
            self.isShowingVolumeHUD = true
        }

        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                self.isShowingVolumeHUD = false
            }
        }
        self.volumeHUDDismissItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: item)
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

    func cycleNextMode() {
        HapticService.shared.heavy()
        let all = IslandMode.allCases
        if let idx = all.firstIndex(of: mode) {
            let nextIdx = (idx + 1) % all.count
            let nextMode = all[nextIdx]
            setMode(nextMode)
            triggerNotification(
                title: nextMode.rawValue,
                subtitle: "Mode Switched",
                icon: iconForMode(nextMode),
                color: theme.color
            )
        }
    }

    func iconForMode(_ mode: IslandMode) -> String {
        switch mode {
        case .media: return "music.note"
        case .call: return "phone.fill"
        case .timer: return "timer"
        case .stopwatch: return "stopwatch"
        case .battery: return "battery.100.bolt"
        case .silent: return "bell.badge.fill"
        }
    }

    func setSize(_ newSize: IslandSize) {
        self.size = newSize
        self.useCustomSize = false
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func applyPreset(_ preset: DeviceNotchPreset) {
        self.selectedPreset = preset
        let dims = preset.dimensions
        self.customWidth = dims.width
        self.customHeight = dims.height
        self.customCornerRadius = dims.cornerRadius
        self.useCustomSize = true
        HapticService.shared.selection()
        PiPIslandManager.shared.updateSize(width: dims.width, height: dims.height)
    }

    func updateCustomCalibration(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        self.customWidth = width
        self.customHeight = height
        self.customCornerRadius = cornerRadius
        self.useCustomSize = true
        self.selectedPreset = .custom
        PiPIslandManager.shared.updateSize(width: width, height: height)
    }

    func toggleSilentMode() {
        self.isSilentOn.toggle()
        HapticService.shared.medium()
        triggerNotification(
            title: isSilentOn ? "Silent Mode" : "Ring Mode",
            subtitle: isSilentOn ? "Mute Active • Haptics Only" : "Sound Enabled • Ringing",
            icon: isSilentOn ? "bell.slash.fill" : "bell.fill",
            color: isSilentOn ? .red : .green
        )
    }

    func handleDoubleTap() {
        HapticService.shared.doubleTapHaptic()
        switch doubleTapAction {
        case .playPause:
            NowPlayingService.shared.togglePlayPause()
        case .nextTrack:
            NowPlayingService.shared.nextTrack()
        case .toggleTorch:
            TorchService.shared.toggleTorch()
        case .toggleSilent:
            toggleSilentMode()
        case .expandCollapse:
            toggleExpanded()
        }
    }

    private var lastToggleTime: Date = Date.distantPast

    func toggleExpanded() {
        let now = Date()
        guard now.timeIntervalSince(lastToggleTime) > 0.25 else { return }
        lastToggleTime = now

        HapticService.shared.medium()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            self.isExpanded.toggle()
            if !self.isExpanded {
                self.isShowingNotification = false
            }
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    // MARK: - Live Notification Auto-Expansion
    func triggerNotification(
        title: String,
        subtitle: String,
        icon: String = "bell.badge.fill",
        color: Color? = nil
    ) {
        notificationDismissWorkItem?.cancel()
        HapticService.shared.medium()

        DispatchQueue.main.async {
            self.activeNotificationTitle = title
            self.activeNotificationSubtitle = subtitle
            self.activeNotificationIcon = icon
            self.activeNotificationColor = color
            self.isShowingNotification = true
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                self.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(width: self.islandWidth, height: self.islandHeight)

            let workItem = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                withAnimation(.spring(response: 0.38, dampingFraction: 0.75)) {
                    self.isShowingNotification = false
                    self.isExpanded = false
                }
                PiPIslandManager.shared.updateSize(width: self.islandWidth, height: self.islandHeight)
            }
            self.notificationDismissWorkItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.8, execute: workItem)
        }
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
                } else {
                    self.isTimerRunning = false
                    AudioServicesPlayAlertSound(1005)
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    self.triggerNotification(
                        title: "Focus Complete",
                        subtitle: "Session finished!",
                        icon: "timer",
                        color: .orange
                    )
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

    func recordLap() {
        HapticService.shared.light()
        let lapTime = stopwatchFormatted
        let lapNumber = stopwatchLaps.count + 1
        stopwatchLaps.insert("Lap \(lapNumber) — \(lapTime)", at: 0)
    }

    func resetStopwatch() {
        stopwatchCancellable?.cancel()
        stopwatchSeconds = 0.0
        isStopwatchRunning = false
        stopwatchLaps.removeAll()
    }

    // MARK: - Call HUD Logic
    func answerCall() {
        HapticService.shared.success()
        withAnimation {
            isCallActive = true
            callerName = "Connected Call"
            callerSubtitle = "00:01"
            callDuration = 1
        }
        startCallTimer()
    }

    func declineCall() {
        HapticService.shared.heavy()
        callTimer?.cancel()
        withAnimation {
            isCallActive = false
            callerName = "Call Ended"
            callerSubtitle = "Dismissed"
        }
    }

    private func startCallTimer() {
        callTimer?.cancel()
        callTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isCallActive else { return }
                self.callDuration += 1
                let m = self.callDuration / 60
                let s = self.callDuration % 60
                self.callerSubtitle = String(format: "%02d:%02d", m, s)
            }
    }

    func toggleCallMute() {
        HapticService.shared.light()
        isCallMuted.toggle()
    }

    func toggleSpeaker() {
        HapticService.shared.light()
        isSpeakerOn.toggle()
    }
}
