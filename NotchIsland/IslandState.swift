import SwiftUI
import Combine
import AudioToolbox
import AVFoundation

enum IslandMode: String, CaseIterable {
    case blank = "Blank / Stealth"
    case media = "Music & Battery"
    case call = "Call HUD"
    case navigation = "Apple Maps"
    case sports = "Live Sports"
    case recording = "Voice Memo"
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
    case auroraBorealis = "Aurora Borealis"
    case sunsetHorizon = "Sunset Horizon"

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
        case .auroraBorealis: return "sparkles"
        case .sunsetHorizon: return "sunset.fill"
        }
    }
}

enum VisualizerStyle: String, CaseIterable, Identifiable {
    case equalizer = "Classic Bars"
    case pulseWave = "Audio Waveform"
    case breathingDot = "Breathing Dot"
    case neonGlow = "Neon Frequency"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .equalizer: return "chart.bar.fill"
        case .pulseWave: return "waveform"
        case .breathingDot: return "circle.circle.fill"
        case .neonGlow: return "sparkles"
        }
    }
}

enum VisualizerSpeed: String, CaseIterable, Identifiable {
    case gentle = "Gentle"
    case balanced = "Balanced"
    case energetic = "Energetic"

    var id: String { rawValue }

    var multiplier: Double {
        switch self {
        case .gentle: return 1.4
        case .balanced: return 1.0
        case .energetic: return 0.65
        }
    }
}

enum VisualizerColorMode: String, CaseIterable, Identifiable {
    case adaptive = "Adaptive"
    case theme = "Accent"
    case rainbow = "Cyan Glow"
    case white = "White"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .adaptive: return "wand.and.stars"
        case .theme: return "paintpalette.fill"
        case .rainbow: return "sparkles"
        case .white: return "sun.max.fill"
        }
    }
}

enum DoubleTapAction: String, CaseIterable, Identifiable {
    case playPause = "Play / Pause"
    case nextTrack = "Next Track"
    case toggleMute = "Mute / Unmute"
    case toggleTorch = "Toggle Torch"
    case toggleSOS = "Toggle SOS Beacon"
    case toggleSilent = "Toggle Silent"
    case cycleVisualizer = "Cycle Visualizer"
    case stealthMode = "Stealth Mode"
    case expandCollapse = "Expand / Collapse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .playPause: return "playpause.fill"
        case .nextTrack: return "forward.fill"
        case .toggleMute: return "speaker.slash.fill"
        case .toggleTorch: return "flashlight.on.fill"
        case .toggleSOS: return "exclamationmark.shield.fill"
        case .toggleSilent: return "bell.slash.fill"
        case .cycleVisualizer: return "waveform"
        case .stealthMode: return "eye.slash.fill"
        case .expandCollapse: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
}

enum IslandAnimationProfile: String, CaseIterable, Identifiable {
    case appleBouncy = "Bouncy"
    case snappy = "Snappy"
    case gentle = "Smooth"

    var id: String { rawValue }

    var response: Double {
        switch self {
        case .appleBouncy: return 0.35
        case .snappy: return 0.26
        case .gentle: return 0.45
        }
    }

    var damping: Double {
        switch self {
        case .appleBouncy: return 0.72
        case .snappy: return 0.82
        case .gentle: return 0.88
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
    @Published var autoSwitchModes: Bool = true

    // MARK: - Visualizer & Multi-Activity
    @Published var visualizerStyle: VisualizerStyle = .equalizer
    @Published var visualizerSpeed: VisualizerSpeed = .balanced
    @Published var visualizerColorMode: VisualizerColorMode = .adaptive
    @Published var dualActivityEnabled: Bool = true
    @Published var clipboardHUDEnabled: Bool = true
    private var lastClipboardChangeCount: Int = UIPasteboard.general.changeCount

    var isDualActivityActive: Bool {
        return dualActivityEnabled && mode == .media && isTimerRunning && remainingSeconds > 0 && remainingSeconds < totalSeconds
    }

    // MARK: - Background Customization
    @Published var backgroundStyle: IslandBackgroundStyle = .oledBlack
    @Published var backgroundOpacity: Double = 1.0

    // MARK: - Double-Tap Action
    @Published var doubleTapAction: DoubleTapAction = .playPause
    @Published var animationProfile: IslandAnimationProfile = .appleBouncy

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

    // MARK: - Voice Memo Recording State
    @Published var isRecordingActive: Bool = false
    @Published var recordingDuration: Int = 34
    private var recordingTimer: AnyCancellable?

    var recordingTimeFormatted: String {
        let m = recordingDuration / 60
        let s = recordingDuration % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Navigation HUD State
    @Published var navInstruction: String = "Turn Right onto Apple Park Way"
    @Published var navDistance: String = "In 300 ft"
    @Published var navETA: String = "12:45 PM • 14 min"
    @Published var navSpeedLimit: Int = 45

    // MARK: - Live Sports State
    @Published var sportsHomeTeam: String = "RMA"
    @Published var sportsAwayTeam: String = "FCB"
    @Published var sportsHomeScore: Int = 2
    @Published var sportsAwayScore: Int = 1
    @Published var sportsMatchTime: String = "78'"
    @Published var sportsLeague: String = "Champions League • Semi-Final"
    @Published var sportsScorers: String = "Vini Jr. 23', Jude 67' • Robert 41'"

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
            guard let self = self else { return }
            self.isMediaPlaying = playing
            self.evaluateActiveMode()
        }.store(in: &cancellables)

        setupVolumeObserver()
        setupClipboardObserver()
        startTimer()
    }

    private func setupClipboardObserver() {
        NotificationCenter.default.addObserver(
            forName: UIPasteboard.changedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self, self.clipboardHUDEnabled else { return }
            let count = UIPasteboard.general.changeCount
            guard count != self.lastClipboardChangeCount else { return }
            self.lastClipboardChangeCount = count

            if let text = UIPasteboard.general.string, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let preview = text.trimmingCharacters(in: .whitespacesAndNewlines)
                let display = preview.count > 34 ? "\(preview.prefix(32))..." : preview
                self.triggerNotification(
                    title: "Copied to Clipboard",
                    subtitle: display,
                    icon: "doc.on.clipboard.fill",
                    color: Color(red: 0.0, green: 0.94, blue: 1.0)
                )
            }
        }
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

    func setSystemVolume(_ level: Float) {
        self.systemVolume = max(0.0, min(1.0, level))
        self.volumeHUDDismissItem?.cancel()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
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
        case .blank:
            break
        case .media:
            break
        case .call:
            callDuration = 0
            isCallActive = false
        case .navigation:
            break
        case .sports:
            break
        case .recording:
            if !isRecordingActive {
                isRecordingActive = true
                startRecordingTimer()
            }
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

    func evaluateActiveMode() {
        guard autoSwitchModes else { return }

        // 1. Phone Call Active or Incoming
        if isCallActive || callerName == "Incoming Call" {
            if mode != .call {
                setMode(.call)
            }
            return
        }

        // 2. Voice Memo Recording Active
        if isRecordingActive {
            if mode != .recording {
                setMode(.recording)
            }
            return
        }

        // 2. Music / Media Streaming Active
        if isMediaPlaying {
            if mode != .media {
                setMode(.media)
            }
            return
        }

        // 3. Focus Timer Active
        if isTimerRunning && remainingSeconds > 0 && remainingSeconds < totalSeconds {
            if mode != .timer {
                setMode(.timer)
            }
            return
        }

        // 4. Stopwatch Running
        if isStopwatchRunning {
            if mode != .stopwatch {
                setMode(.stopwatch)
            }
            return
        }

        // 5. Idle: Gracefully return to Blank mode after brief grace period
        if mode == .media && !isMediaPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self, self.autoSwitchModes else { return }
                if !self.isMediaPlaying && !self.isCallActive && !self.isStopwatchRunning {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        self.setMode(.blank)
                    }
                }
            }
            return
        }

        if mode != .blank && !isCallActive && !isMediaPlaying && !isStopwatchRunning {
            setMode(.blank)
        }
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
        case .blank: return "eye.slash.fill"
        case .media: return "music.note"
        case .call: return "phone.fill"
        case .navigation: return "arrow.turn.up.right"
        case .sports: return "sportscourt.fill"
        case .recording: return "record.circle.fill"
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
        HapticService.shared.silentSwitchHaptic(isSilent: isSilentOn)
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
        case .toggleMute:
            if systemVolume > 0 {
                setSystemVolume(0.0)
            } else {
                setSystemVolume(0.75)
            }
        case .toggleTorch:
            TorchService.shared.toggleTorch()
        case .toggleSOS:
            TorchService.shared.toggleSOS()
        case .toggleSilent:
            toggleSilentMode()
        case .cycleVisualizer:
            cycleNextVisualizer()
        case .stealthMode:
            if mode == .blank {
                setMode(.media)
            } else {
                setMode(.blank)
            }
        case .expandCollapse:
            toggleExpanded()
        }
    }

    func cycleNextVisualizer() {
        let all = VisualizerStyle.allCases
        if let idx = all.firstIndex(of: visualizerStyle) {
            let next = all[(idx + 1) % all.count]
            self.visualizerStyle = next
            HapticService.shared.selection()
            triggerNotification(
                title: "Visualizer Changed",
                subtitle: next.rawValue,
                icon: next.icon,
                color: theme.color
            )
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

    func toggleTimer() {
        isTimerRunning.toggle()
        HapticService.shared.selection()
        if isTimerRunning {
            startTimer()
        }
    }

    func adjustTimer(by seconds: Double) {
        remainingSeconds = max(0, remainingSeconds + seconds)
        if remainingSeconds > totalSeconds {
            totalSeconds = remainingSeconds
        }
        HapticService.shared.light()
    }

    func resetTimer() {
        remainingSeconds = totalSeconds
        isTimerRunning = false
        HapticService.shared.medium()
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

    // MARK: - Interactive Test Lab Simulators
    func testSimulateChargerPlug() {
        isCharging = true
        HapticService.shared.chargeHaptic()
        triggerNotification(
            title: "Charging Started",
            subtitle: "\(batteryPercentage)% • Fast Charging (20W)",
            icon: "bolt.fill",
            color: .green
        )
    }

    func testSimulateAirPodsConnect() {
        NowPlayingService.shared.currentRouteType = .airPodsPro
        NowPlayingService.shared.currentRouteName = "AirPods Pro"
        NowPlayingService.shared.accessoryBattery = 95
        HapticService.shared.success()
        triggerNotification(
            title: "AirPods Pro",
            subtitle: "Connected • 95% Battery • Spatial Audio",
            icon: "airpodspro",
            color: Color(red: 0.18, green: 0.84, blue: 0.38)
        )
    }

    func testSimulateLowBattery() {
        HapticService.shared.warning()
        triggerNotification(
            title: "Low Battery",
            subtitle: "10% Remaining • Connect Charger",
            icon: "battery.25",
            color: .red
        )
    }

    func testSimulateFullCharge() {
        HapticService.shared.success()
        triggerNotification(
            title: "Fully Charged",
            subtitle: "Battery 100% • Optimal Cell Health",
            icon: "battery.100.bolt",
            color: .green
        )
    }

    func testSimulateThermal() {
        HapticService.shared.warning()
        triggerNotification(
            title: "Device Hot (43.2°C)",
            subtitle: "iPhone needs to cool down",
            icon: "thermometer.sun.fill",
            color: .red
        )
    }

    func testSimulateTimerFinish() {
        HapticService.shared.heavy()
        AudioServicesPlayAlertSound(1005)
        triggerNotification(
            title: "Focus Complete",
            subtitle: "25:00 Session finished!",
            icon: "timer",
            color: .orange
        )
    }

    func testSimulateClipboard() {
        HapticService.shared.light()
        triggerNotification(
            title: "Copied to Clipboard",
            subtitle: "https://github.com/Salomgamer/NotchIsland",
            icon: "doc.on.clipboard.fill",
            color: Color(red: 0.0, green: 0.94, blue: 1.0)
        )
    }

    func testSimulateIncomingCall() {
        HapticService.shared.medium()
        withAnimation {
            callerName = "Tim Cook"
            callerSubtitle = "Apple Park • Cupertino"
            isCallActive = false
            setMode(.call)
            isExpanded = true
        }
    }

    // MARK: - Voice Memo Recording Actions
    func toggleRecording() {
        HapticService.shared.heavy()
        isRecordingActive.toggle()
        if isRecordingActive {
            startRecordingTimer()
            triggerNotification(
                title: "Voice Memo",
                subtitle: "Recording Active • 48kHz Stereo",
                icon: "record.circle.fill",
                color: .red
            )
        } else {
            recordingTimer?.cancel()
            triggerNotification(
                title: "Voice Memo Saved",
                subtitle: "Saved to Library (\(recordingTimeFormatted))",
                icon: "checkmark.circle.fill",
                color: .green
            )
        }
    }

    func startRecordingTimer() {
        recordingTimer?.cancel()
        recordingTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isRecordingActive else { return }
                self.recordingDuration += 1
            }
    }

    // MARK: - Expanded Test Lab Simulators
    func testSimulateFaceID() {
        HapticService.shared.success()
        triggerNotification(
            title: "Face ID",
            subtitle: "Verified Successfully",
            icon: "faceid",
            color: Color(red: 0.18, green: 0.84, blue: 0.38)
        )
    }

    func testSimulateAirDrop() {
        HapticService.shared.medium()
        triggerNotification(
            title: "AirDrop",
            subtitle: "Receiving 4 Photos from Sarah...",
            icon: "antenna.radiowaves.left.and.right",
            color: Color(red: 0.0, green: 0.55, blue: 1.0)
        )
    }

    func testSimulateHotspot() {
        HapticService.shared.success()
        triggerNotification(
            title: "Personal Hotspot",
            subtitle: "MacBook Pro Connected • 1 Device",
            icon: "personalhotspot",
            color: Color(red: 0.18, green: 0.84, blue: 0.38)
        )
    }

    func testSimulateVoiceMemo() {
        if !isRecordingActive {
            toggleRecording()
        } else {
            toggleRecording()
        }
    }
}
