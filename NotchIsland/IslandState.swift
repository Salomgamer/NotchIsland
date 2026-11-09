import SwiftUI
import Combine
import AudioToolbox
import AVFoundation

enum IslandMode: String, CaseIterable {
    case blank = "Blank / Stealth"
    case media = "Music & Battery"
    case flashlight = "Flashlight"
    case call = "Call HUD"
    case applePay = "Apple Pay / NFC"
    case airPods = "AirPods Pro Battery"
    case rideshare = "Uber / Rideshare"
    case flight = "Flight Tracker"
    case delivery = "Food Delivery"
    case screenRecording = "Screen Recording"
    case hotspot = "Personal Hotspot"
    case airDrop = "AirDrop Transfer"
    case cellular = "Dual SIM / Cellular"
    case gamePong = "Hit The Island"
    case navigation = "Apple Maps"
    case sports = "Live Sports"
    case recording = "Voice Memo"
    case timer = "Timer"
    case stopwatch = "Stopwatch"
    case battery = "Battery"
    case silent = "Silent HUD"
}

enum SecondaryIslandActivity: String, CaseIterable, Identifiable {
    case timer = "Timer Countdown"
    case stopwatch = "Stopwatch"
    case recording = "Voice Memo"
    case navigation = "Next Turn"
    case sports = "Match Score"
    case battery = "Battery Level"
    case micPrivacy = "Microphone Dot"
    case cameraPrivacy = "Camera Dot"
    case hotspot = "Hotspot"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .timer: return "timer"
        case .stopwatch: return "stopwatch"
        case .recording: return "record.circle"
        case .navigation: return "arrow.turn.up.right"
        case .sports: return "sportscourt.fill"
        case .battery: return "bolt.fill"
        case .micPrivacy: return "mic.fill"
        case .cameraPrivacy: return "camera.fill"
        case .hotspot: return "personalhotspot"
        }
    }

    var color: Color {
        switch self {
        case .timer: return .orange
        case .stopwatch: return Color(red: 0.0, green: 0.85, blue: 1.0)
        case .recording: return .red
        case .navigation: return Color(red: 0.18, green: 0.84, blue: 0.38)
        case .sports: return .green
        case .battery: return Color(red: 0.18, green: 0.84, blue: 0.38)
        case .micPrivacy: return .orange
        case .cameraPrivacy: return .green
        case .hotspot: return Color(red: 0.18, green: 0.84, blue: 0.38)
        }
    }
}

enum ApplePayPhase: String {
    case ready
    case authenticating
    case done
}

enum BubbleTouchAction: String, CaseIterable, Identifiable {
    case smartAdaptive = "Smart Adaptive"
    case openApp = "Open Active App"
    case expandOnly = "Expand Island In-Place"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .smartAdaptive: return "Smart Adaptive (Recommended)"
        case .openApp: return "Open Active App (Apple Native)"
        case .expandOnly: return "Expand Dynamic Island In-Place"
        }
    }

    var subtitle: String {
        switch self {
        case .smartAdaptive: return "Opens Spotify/Clock/Maps if active; expands island if idle"
        case .openApp: return "Directly opens the app of whatever is currently happening"
        case .expandOnly: return "Expands the island into interactive HUD without opening settings"
        }
    }

    var icon: String {
        switch self {
        case .smartAdaptive: return "sparkles"
        case .openApp: return "arrow.up.forward.app.fill"
        case .expandOnly: return "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left"
        }
    }
}


enum PiPDockAlignment: String, CaseIterable, Identifiable {
    case topFlush = "Top Flush (Lock Under Notch)"
    case center = "Centered (Floating)"
    case fillPlatter = "Smart Platter (Fill Height)"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .topFlush: return "Top Flush (Under Notch)"
        case .center: return "Centered (Floating)"
        case .fillPlatter: return "Smart Platter (Fill Height)"
        }
    }

    var subtitle: String {
        switch self {
        case .topFlush: return "Pins pill flush against top bezel with zero wasted top margin"
        case .center: return "Traditional centered floating island inside the PiP frame"
        case .fillPlatter: return "Expands to 74pt to fill native PiP window with zero letterbox shadow"
        }
    }

    var verticalAlignment: Alignment {
        switch self {
        case .topFlush: return .top
        case .center: return .center
        case .fillPlatter: return .center
        }
    }
}

enum CompanionType: String, CaseIterable, Identifiable {
    case cat = "Pixel Cat"
    case dog = "Puppy"
    case fox = "Fox"
    case axolotl = "Axolotl"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐶"
        case .fox: return "🦊"
        case .axolotl: return "🦎"
        }
    }
}

enum CompanionAction: String {
    case walking
    case sleeping
    case dancing
    case jumping
}

enum IslandSize: String, CaseIterable {
    case slim = "Slim (144×32)"
    case compact = "Compact (156×36)"
    case expanded = "Expanded (216×68)"
}


enum IslandShape: String, CaseIterable, Identifiable {
    case compactRect = "Compact Rectangle (192×112)"
    case tinySquare = "Tiny Square (1:1 Orbit)"
    case pill = "Dynamic Pill (Wide Bar)"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .compactRect: return "Compact Rectangle (Left Locked)"
        case .tinySquare: return "Tiny Square (1:1)"
        case .pill: return "Dynamic Pill (Wide Bar)"
        }
    }

    var subtitle: String {
        switch self {
        case .compactRect: return "192×112 pt rectangular PiP locked flush to left side, unchangeable"
        case .tinySquare: return "192×192 pt square PiP locked to left side"
        case .pill: return "Traditional wide pill under the physical camera notch"
        }
    }
}

enum DockSide: String, CaseIterable, Identifiable {
    case left = "Left Side"
    case right = "Right Side"

    var id: String { rawValue }
}

enum DeviceNotchPreset: String, CaseIterable, Identifiable {
    case compactRect = "Compact Rectangle (192×112)"
    case tinySquare = "Tiny Square (1:1 Orbit)"
    case iphone11 = "iPhone 11 / XR"
    case iphone12 = "iPhone 12 / 12 Pro"
    case iphone13 = "iPhone 13 / 14"
    case iphone14Pro = "iPhone 14 Pro / 15 / 16 (Pill)"
    case compactSE = "SE / Home Button (Compact)"
    case custom = "Custom Notch"

    var id: String { rawValue }

    var dimensions: (width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        switch self {
        case .compactRect:
            return (width: 192, height: 112, cornerRadius: 22)
        case .tinySquare:
            return (width: 192, height: 192, cornerRadius: 28)
        case .iphone11:
            return (width: 156, height: 36, cornerRadius: 18)
        case .iphone12:
            return (width: 150, height: 35, cornerRadius: 17.5)
        case .iphone13:
            return (width: 138, height: 34, cornerRadius: 17)
        case .iphone14Pro:
            return (width: 124, height: 36, cornerRadius: 18)
        case .compactSE:
            return (width: 132, height: 32, cornerRadius: 16)
        case .custom:
            return (width: 156, height: 36, cornerRadius: 18)
        }
    }

    var badge: String {
        switch self {
        case .tinySquare: return "72×72"
        case .iphone11: return "156×36"
        case .iphone12: return "150×35"
        case .iphone13: return "138×34"
        case .iphone14Pro: return "124×36"
        case .compactSE: return "132×32"
        case .custom: return "Custom"
        }
    }
}

enum IslandBackgroundStyle: String, CaseIterable, Identifiable {
    case liquidWallpaperGlass = "Liquid Wallpaper Glass"
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
        case .liquidWallpaperGlass: return "drop.fill"
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

enum SoundEQProfile: String, CaseIterable, Identifiable {
    case balanced = "Balanced Studio"
    case bassBoost = "Bass Booster"
    case vocal = "Vocal Clarity"
    case acoustic = "Acoustic Warmth"
    case electronic = "Electronic Dance"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .balanced: return "slider.horizontal.3"
        case .bassBoost: return "speaker.wave.3.fill"
        case .vocal: return "mic.fill"
        case .acoustic: return "guitars.fill"
        case .electronic: return "bolt.horizontal.fill"
        }
    }

    var barMultipliers: [CGFloat] {
        switch self {
        case .balanced: return [1.0, 1.0, 1.0, 1.0]
        case .bassBoost: return [1.35, 1.15, 0.65, 0.50]
        case .vocal: return [0.55, 1.25, 1.20, 0.60]
        case .acoustic: return [0.65, 0.85, 1.10, 1.30]
        case .electronic: return [1.20, 0.75, 1.15, 1.05]
        }
    }
}

enum FocusProfile: String, CaseIterable, Identifiable {
    case dnd = "Do Not Disturb"
    case work = "Work Focus"
    case sleep = "Sleep Focus"
    case personal = "Personal"
    case fitness = "Fitness"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dnd: return "moon.fill"
        case .work: return "briefcase.fill"
        case .sleep: return "bed.double.fill"
        case .personal: return "person.fill"
        case .fitness: return "figure.run"
        }
    }

    var color: Color {
        switch self {
        case .dnd: return Color(red: 0.68, green: 0.32, blue: 0.95)
        case .work: return Color.orange
        case .sleep: return Color.cyan
        case .personal: return Color(red: 0.18, green: 0.84, blue: 0.38)
        case .fitness: return Color.red
        }
    }
}

enum DoubleTapAction: String, CaseIterable, Identifiable {
    case playPause = "Play / Pause"
    case nextTrack = "Next Track"
    case toggleMute = "Mute / Unmute"
    case cycleEQ = "Cycle EQ Profile"
    case cycleFocus = "Cycle Focus (DND)"
    case cycleBrightness = "Cycle Brightness"
    case toggleTorch = "Toggle Torch"
    case toggleSOS = "Toggle SOS Beacon"
    case toggleSilent = "Toggle Silent"
    case toggleTimer = "Toggle Focus Timer"
    case copySongInfo = "Copy Track to Clipboard"
    case testFaceID = "Simulate Face ID"
    case cycleVisualizer = "Cycle Visualizer"
    case cycleTheme = "Cycle Theme Accent"
    case toggleSplit = "Toggle Split Island"
    case toggleCompanion = "Toggle Notch Pet"
    case playPong = "Play Hit The Island"
    case stealthMode = "Stealth Mode"
    case expandCollapse = "Expand / Collapse"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .playPause: return "playpause.fill"
        case .nextTrack: return "forward.fill"
        case .toggleMute: return "speaker.slash.fill"
        case .cycleEQ: return "slider.horizontal.3"
        case .cycleFocus: return "moon.fill"
        case .cycleBrightness: return "sun.max.fill"
        case .toggleTorch: return "flashlight.on.fill"
        case .toggleSOS: return "exclamationmark.shield.fill"
        case .toggleSilent: return "bell.slash.fill"
        case .toggleTimer: return "timer"
        case .copySongInfo: return "doc.on.doc.fill"
        case .testFaceID: return "faceid"
        case .cycleVisualizer: return "waveform"
        case .cycleTheme: return "paintpalette.fill"
        case .toggleSplit: return "rectangle.split.2x1.fill"
        case .toggleCompanion: return "pawprint.fill"
        case .playPong: return "circle.and.line.horizontal.fill"
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
    @Published var soundEQProfile: SoundEQProfile = .balanced
    @Published var dualActivityEnabled: Bool = true
    @Published var clipboardHUDEnabled: Bool = true
    private var lastClipboardChangeCount: Int = UIPasteboard.general.changeCount

    var isDualActivityActive: Bool {
        return dualActivityEnabled && mode == .media && isTimerRunning && remainingSeconds > 0 && remainingSeconds < totalSeconds
    }

    // MARK: - Background Customization
    @Published var backgroundStyle: IslandBackgroundStyle = .liquidWallpaperGlass
    @Published var backgroundOpacity: Double = 1.0

    // MARK: - Double-Tap Action
    @Published var doubleTapAction: DoubleTapAction = .playPause
    @Published var animationProfile: IslandAnimationProfile = .appleBouncy

    // MARK: - Focus & Do Not Disturb State
    @Published var currentFocus: FocusProfile? = nil

    // MARK: - Island Shape & Form Factor
    @Published var islandShape: IslandShape = .compactRect
    @Published var rectWidth: CGFloat = 192
    @Published var rectHeight: CGFloat = 112
    @Published var squareSize: CGFloat = 192
    @Published var isSquareLocked: Bool = true
    @Published var squareDockSide: DockSide = .left

    // MARK: - Custom Size Calibration & Presets
    @Published var selectedPreset: DeviceNotchPreset = .iphone11
    @Published var useCustomSize: Bool = false
    @Published var customWidth: CGFloat = 156
    @Published var customHeight: CGFloat = 36
        @Published var customCornerRadius: CGFloat = 18

    // MARK: - PiP Window Frame, Docking & Shadow Engine
    @Published var pipDockAlignment: PiPDockAlignment = .topFlush
    @Published var enableShadow: Bool = false
    @Published var shadowOpacity: Double = 0.0

    // MARK: - Notification Banner State
    @Published var activeNotificationTitle: String = ""
    @Published var activeNotificationSubtitle: String = ""
    @Published var activeNotificationIcon: String = "bell.badge.fill"
    @Published var activeNotificationColor: Color? = nil
    @Published var isShowingNotification: Bool = false
    @Published var isFaceIDScanning: Bool = false
    @Published var faceIDVerified: Bool = false
    private var notificationDismissWorkItem: DispatchWorkItem?

    // MARK: - Volume HUD State
    @Published var systemVolume: Float = 0.5
    @Published var isShowingVolumeHUD: Bool = false
    private var volumeHUDDismissItem: DispatchWorkItem?

    // MARK: - Brightness HUD State
    @Published var systemBrightness: Float = 0.70
    @Published var isShowingBrightnessHUD: Bool = false
    private var brightnessHUDDismissItem: DispatchWorkItem?

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
    @Published var isNavigationActive: Bool = false
    @Published var navInstruction: String = "Turn Right onto Apple Park Way"
    @Published var navDistance: String = "In 300 ft"
    @Published var navETA: String = "12:45 PM • 14 min"
    @Published var navSpeedLimit: Int = 45

    // MARK: - Live Sports State
    @Published var isSportsActive: Bool = false
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

    // MARK: - Jindo Split Island Architecture (Dual Multi-Activity)
    @Published var isSplitIslandActive: Bool = false
    @Published var secondaryActivity: SecondaryIslandActivity = .timer
    @Published var isSplitBubbleExpanded: Bool = false

    // MARK: - Gesture Physics & Stealth State
    @Published var dragOffset: CGSize = .zero
    @Published var isIslandHidden: Bool = false

    // MARK: - Apple Pay & Wallet State
    @Published var applePayPhase: ApplePayPhase = .ready
    @Published var applePayCardName: String = "Apple Card"
    @Published var applePayMerchant: String = "Apple Park Visitor Center"
    @Published var applePayAmount: String = "$14.50"

    // MARK: - AirPods Pro HUD State
    @Published var airPodsModelName: String = "AirPods Pro (2nd gen)"
    @Published var airPodsLeftBattery: Int = 96
    @Published var airPodsRightBattery: Int = 92
    @Published var airPodsCaseBattery: Int = 100
    @Published var isAirPodsCaseCharging: Bool = true
    @Published var airPodsNoiseCancellationOn: Bool = true

    // MARK: - Uber / Rideshare Live Activity State
    @Published var rideshareService: String = "UberX"
    @Published var rideshareCar: String = "Black Toyota Prius"
    @Published var ridesharePlate: String = "7XYZ890"
    @Published var rideshareDriver: String = "David"
    @Published var rideshareRating: String = "4.98 ★"
    @Published var rideshareEta: String = "3 min away"
    @Published var rideshareProgress: Double = 0.72

    // MARK: - Flight Tracker (Flighty) State
    @Published var flightAirline: String = "United Airlines"
    @Published var flightNumber: String = "UA 2408"
    @Published var flightOrigin: String = "SFO"
    @Published var flightDestination: String = "JFK"
    @Published var flightStatus: String = "On Time"
    @Published var flightGate: String = "B22"
    @Published var flightBaggage: String = "Carousel 4"
    @Published var flightRemainingTime: String = "1h 45m remaining"
    @Published var flightProgress: Double = 0.65

    // MARK: - Food Delivery (DoorDash) State
    @Published var deliveryRestaurant: String = "Shake Shack"
    @Published var deliveryCourier: String = "Alex (E-Bike)"
    @Published var deliveryEta: String = "12:35 PM • 4 min"
    @Published var deliveryProgress: Double = 0.82
    @Published var deliveryStatusStep: Int = 3

    // MARK: - Screen Recording State
    @Published var isScreenRecordingActive: Bool = false
    @Published var screenRecordingSeconds: Int = 14
    private var screenRecordingTimer: AnyCancellable?

    // MARK: - Hardware Privacy Dots State
    @Published var isMicPrivacyActive: Bool = false
    @Published var isCamPrivacyActive: Bool = false

    // MARK: - Notch Companion / Pixel Pet
    @Published var companionEnabled: Bool = false
    @Published var companionType: CompanionType = .cat
    @Published var companionAction: CompanionAction = .walking
    @Published var companionOffset: CGFloat = 0.0

    // MARK: - iOS 18 Flashlight Beam Geometry
    @Published var torchBeamWidth: Double = 0.50

    // MARK: - Personal Hotspot Telemetry
    @Published var hotspotConnectedDevices: Int = 2
    @Published var hotspotUploadSpeed: String = "1.4 MB/s"
    @Published var hotspotDownloadSpeed: String = "5.2 MB/s"

    // MARK: - AirDrop Transfer State
    @Published var airDropSender: String = "Sarah's iPhone"
    @Published var airDropFileCount: Int = 4
    @Published var airDropProgress: Double = 0.65
    @Published var isAirDropCompleted: Bool = false

    // MARK: - Dual SIM Cellular State
    @Published var primaryCarrier: String = "Verizon 5G UW"
    @Published var secondaryCarrier: String = "T-Mobile LTE"
    @Published var primarySignalBars: Int = 4
    @Published var secondarySignalBars: Int = 3

    // MARK: - Hit The Island (Pong Game) State
    @Published var pongScore: Int = 0
    @Published var pongHighScore: Int = 14
    @Published var isPongPlaying: Bool = false
    @Published var islandSquishScale: CGFloat = 1.0

    // MARK: - Bubble Touch Behavior (Expand vs Open Active App)
    @Published var bubbleTouchAction: BubbleTouchAction = .smartAdaptive
    @Published var isExpandedViaPiPTap: Bool = false
    @Published var isBubbleClear: Bool = true

    private var timerCancellable: AnyCancellable?
    private var stopwatchCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    var islandWidth: CGFloat {
        if isShowingNotification { return 232 }
        if isIslandHidden { return 36 }
        if islandShape == .compactRect && !isExpanded {
            return rectWidth
        }
        if islandShape == .tinySquare && !isExpanded {
            return squareSize
        }
        if isExpanded {
            if isSplitBubbleExpanded { return 184 }
            switch mode {
            case .call: return 242
            case .media: return 232
            case .applePay: return 246
            case .airPods: return 242
            case .rideshare: return 244
            case .flight: return 248
            case .delivery: return 242
            case .screenRecording: return 232
            case .hotspot: return 238
            case .airDrop: return 240
            case .cellular: return 236
            case .gamePong: return 240
            case .blank: return 236
            default: return 228
            }
        }
        if isSplitIslandActive {
            return 168
        }
        if islandShape == .tinySquare && !isExpanded {
            return squareSize
        }
        if useCustomSize { return customWidth }
        switch size {
        case .slim: return 144
        case .compact: return 156
        case .expanded: return 186
        }
    }

    var islandHeight: CGFloat {
        if isShowingNotification { return 66 }
        if isIslandHidden { return 12 }
        if islandShape == .compactRect && !isExpanded {
            return rectHeight
        }
        if islandShape == .tinySquare && !isExpanded {
            return squareSize
        }
        if pipDockAlignment == .fillPlatter && !isExpanded { return 74 }
        if isExpanded {
            if isSplitBubbleExpanded { return 64 }
            switch mode {
            case .call: return 78
            case .media: return 84
            case .applePay: return 88
            case .airPods: return 84
            case .rideshare: return 86
            case .flight: return 88
            case .delivery: return 84
            case .screenRecording: return 72
            case .hotspot: return 74
            case .airDrop: return 76
            case .cellular: return 72
            case .gamePong: return 86
            case .blank: return 72
            default: return 70
            }
        }
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
            } else if wasCharging && !charging {
                self.triggerNotification(
                    title: "Power Disconnected",
                    subtitle: "\(self.batteryPercentage)% • On Battery",
                    icon: "battery.100",
                    color: .white
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

        // 3. Start CallKit and Device Activity Monitoring
        CallService.shared.startMonitoring()
        ActivityObserverService.shared.startMonitoring()
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

    func showBrightnessHUD(level: Float) {
        self.systemBrightness = max(0.05, min(1.0, level))
        self.brightnessHUDDismissItem?.cancel()
        self.isShowingVolumeHUD = false
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            self.isShowingBrightnessHUD = true
        }
        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                self.isShowingBrightnessHUD = false
            }
        }
        self.brightnessHUDDismissItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: item)
    }

    func setSystemBrightness(_ level: Float) {
        let clamped = max(0.05, min(1.0, level))
        self.systemBrightness = clamped
        DispatchQueue.main.async {
            UIScreen.main.brightness = CGFloat(clamped)
        }
        showBrightnessHUD(level: clamped)
        HapticService.shared.light()
    }

    func setMode(_ newMode: IslandMode) {
        self.mode = newMode
        switch newMode {
        case .blank:
            break
        case .media:
            break
        case .flashlight:
            break
        case .call:
            callDuration = 0
            isCallActive = false
        case .applePay, .airPods, .rideshare, .flight, .delivery, .screenRecording, .hotspot, .airDrop, .cellular, .gamePong:
            break
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
        if isCallActive || CallService.shared.hasActiveCall || CallService.shared.isIncoming || callerName == "Incoming Call" {
            if mode != .call {
                setMode(.call)
            }
            return
        }

        // 2. Flashlight / SOS Strobe Active
        if TorchService.shared.isTorchOn || TorchService.shared.isSOSActive {
            if mode != .flashlight {
                setMode(.flashlight)
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

        // 6. Stopwatch Running
        if isStopwatchRunning {
            if mode != .stopwatch {
                setMode(.stopwatch)
            }
            return
        }

        // 7. Navigation Turn-by-Turn Active
        if isNavigationActive {
            if mode != .navigation {
                setMode(.navigation)
            }
            return
        }

        // 8. Live Sports Active
        if isSportsActive {
            if mode != .sports {
                setMode(.sports)
            }
            return
        }

        // 9. Idle: Gracefully return to Blank / Liquid Glass mode after brief grace period
        if mode == .media && !isMediaPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self, self.autoSwitchModes else { return }
                if !self.isMediaPlaying && !self.isCallActive && !self.isStopwatchRunning && !self.isNavigationActive && !self.isSportsActive {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        self.setMode(.blank)
                    }
                }
            }
            return
        }

        if mode != .blank && !isCallActive && !CallService.shared.hasActiveCall && !isMediaPlaying && !isStopwatchRunning && !isNavigationActive && !isSportsActive {
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
        case .flashlight: return "flashlight.on.fill"
        case .call: return "phone.fill"
        case .applePay: return "creditcard.fill"
        case .airPods: return "airpodspro"
        case .rideshare: return "car.fill"
        case .flight: return "airplane"
        case .delivery: return "bag.fill"
        case .screenRecording: return "record.circle"
        case .hotspot: return "personalhotspot"
        case .airDrop: return "antenna.radiowaves.left.and.right"
        case .cellular: return "simcard.fill"
        case .gamePong: return "circle.and.line.horizontal.fill"
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
        if preset == .compactRect {
            self.islandShape = .compactRect
        } else if preset == .tinySquare {
            self.islandShape = .tinySquare
        } else {
            self.islandShape = .pill
        }
        HapticService.shared.selection()
        PiPIslandManager.shared.updateSize(width: dims.width, height: dims.height)
    }

    func setShape(_ shape: IslandShape) {
        self.islandShape = shape
        if shape == .compactRect {
            self.selectedPreset = .compactRect
            self.customWidth = rectWidth
            self.customHeight = rectHeight
            self.customCornerRadius = 22
        } else if shape == .tinySquare {
            self.selectedPreset = .tinySquare
            self.customWidth = squareSize
            self.customHeight = squareSize
            self.customCornerRadius = 28
        } else {
            self.selectedPreset = .iphone11
            self.customWidth = 156
            self.customHeight = 36
            self.customCornerRadius = 18
        }
        HapticService.shared.selection()
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }


    func updateCustomCalibration(width: CGFloat, height: CGFloat, cornerRadius: CGFloat) {
        self.customWidth = width
        self.customHeight = height
        self.customCornerRadius = cornerRadius
        self.useCustomSize = true
        self.selectedPreset = .custom
        PiPIslandManager.shared.updateSize(width: width, height: height)
    }

    func autoFitPiPRatio() {
        self.customWidth = 176
        self.customHeight = 74
        self.customCornerRadius = 22
        self.useCustomSize = true
        self.selectedPreset = .custom
        self.enableShadow = false
        self.shadowOpacity = 0.0
        HapticService.shared.success()
        PiPIslandManager.shared.updateSize(width: 176, height: 74)
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
        case .cycleEQ:
            cycleEQProfile()
        case .cycleFocus:
            cycleNextFocus()
        case .cycleBrightness:
            let levels: [Float] = [0.25, 0.50, 0.75, 1.0]
            let current = systemBrightness
            let next = levels.first { $0 > current + 0.05 } ?? 0.25
            setSystemBrightness(next)
        case .toggleTorch:
            TorchService.shared.toggleTorch()
        case .toggleSOS:
            TorchService.shared.toggleSOS()
        case .toggleSilent:
            toggleSilentMode()
        case .toggleTimer:
            toggleTimer()
        case .copySongInfo:
            let trackText = "\(mediaTitle) - \(mediaArtist)"
            UIPasteboard.general.string = trackText
            HapticService.shared.success()
            triggerNotification(
                title: "Copied Track",
                subtitle: trackText,
                icon: "doc.on.doc.fill",
                color: Color(red: 0.18, green: 0.84, blue: 0.38)
            )
        case .testFaceID:
            testSimulateFaceID()
        case .cycleVisualizer:
            cycleNextVisualizer()
        case .cycleTheme:
            let all = AccentTheme.allCases
            if let idx = all.firstIndex(of: theme) {
                let next = all[(idx + 1) % all.count]
                self.theme = next
                HapticService.shared.selection()
                triggerNotification(
                    title: "Theme Changed",
                    subtitle: next.rawValue,
                    icon: "paintpalette.fill",
                    color: next.color
                )
            }
        case .toggleSplit:
            toggleSplitIsland()
        case .toggleCompanion:
            toggleCompanion()
        case .playPong:
            startPongGame()
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

    func cycleEQProfile() {
        let all = SoundEQProfile.allCases
        if let idx = all.firstIndex(of: soundEQProfile) {
            let next = all[(idx + 1) % all.count]
            self.soundEQProfile = next
            HapticService.shared.selection()
            triggerNotification(
                title: "EQ: \(next.rawValue)",
                subtitle: "Sound equalization frequency curve activated",
                icon: next.icon,
                color: theme.color
            )
        }
    }

    func toggleFocus(_ focus: FocusProfile) {
        if currentFocus == focus {
            currentFocus = nil
            HapticService.shared.light()
            triggerNotification(
                title: "Focus Off",
                subtitle: "\(focus.rawValue) turned off",
                icon: focus.icon,
                color: .gray
            )
        } else {
            currentFocus = focus
            HapticService.shared.medium()
            triggerNotification(
                title: focus.rawValue,
                subtitle: "Active • Notifications Silenced",
                icon: focus.icon,
                color: focus.color
            )
        }
    }

    func cycleNextFocus() {
        let all = FocusProfile.allCases
        if let cur = currentFocus, let idx = all.firstIndex(of: cur) {
            let nextIdx = idx + 1
            if nextIdx < all.count {
                toggleFocus(all[nextIdx])
            } else {
                currentFocus = nil
                HapticService.shared.light()
                triggerNotification(
                    title: "Focus Off",
                    subtitle: "All Focus modes disabled",
                    icon: "moon.slash.fill",
                    color: .gray
                )
            }
        } else {
            toggleFocus(.dnd)
        }
    }

    private var lastToggleTime: Date = Date.distantPast

    func expand() {
        guard !isExpanded else { return }
        HapticService.shared.medium()
        HapticService.shared.expandWhooshSound()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isExpanded = true
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func collapse() {
        guard isExpanded || isShowingNotification else { return }
        HapticService.shared.light()
        HapticService.shared.collapseSnapSound()
        notificationDismissWorkItem?.cancel()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isExpanded = false
            self.isShowingNotification = false
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func toggleExpanded() {
        let now = Date()
        guard now.timeIntervalSince(lastToggleTime) > 0.25 else { return }
        lastToggleTime = now

        if isExpanded {
            collapse()
        } else {
            expand()
        }
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
        let secs = Double(minutes * 60)
        totalSeconds = secs
        remainingSeconds = secs
        isTimerRunning = true
        startTimer()
        HapticService.shared.medium()
        triggerNotification(
            title: minutes == 25 ? "Pomodoro Active" : "\(minutes)m Timer Started",
            subtitle: "Focus Session Countdown",
            icon: "timer",
            color: .orange
        )
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
        HapticService.shared.stopCallRingtone()
        HapticService.shared.success()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            isCallActive = true
            callerName = "Connected Call"
            callerSubtitle = "00:01"
            callDuration = 1
            isExpanded = true
        }
        startCallTimer()
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func declineCall() {
        HapticService.shared.stopCallRingtone()
        HapticService.shared.heavy()
        callTimer?.cancel()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            isCallActive = false
            callerName = "Call Ended"
            callerSubtitle = "Dismissed"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            guard let self = self else { return }
            if !self.isCallActive {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                    self.isExpanded = false
                    self.evaluateActiveMode()
                }
                PiPIslandManager.shared.updateSize(width: self.islandWidth, height: self.islandHeight)
            }
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
        HapticService.shared.startCallRingtone()
        callerName = "Tim Cook"
        callerSubtitle = "Apple Park • Cupertino"
        isCallActive = false
        setMode(.call)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            isExpanded = true
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
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
        isFaceIDScanning = true
        faceIDVerified = false
        HapticService.shared.light()
        triggerNotification(
            title: "Face ID",
            subtitle: "Looking for Face...",
            icon: "faceid",
            color: Color(red: 0.0, green: 0.85, blue: 1.0)
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            guard let self = self else { return }
            self.faceIDVerified = true
            self.isFaceIDScanning = false
            HapticService.shared.success()
            self.triggerNotification(
                title: "Face ID",
                subtitle: "Verified Successfully",
                icon: "checkmark.circle.fill",
                color: Color(red: 0.18, green: 0.84, blue: 0.38)
            )
        }
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

    func testSimulateFitness() {
        HapticService.shared.success()
        triggerNotification(
            title: "Activity Rings Closed!",
            subtitle: "Move 620/500 • Exercise 38m • Stand 12h",
            icon: "figure.run",
            color: Color(red: 1.0, green: 0.25, blue: 0.35)
        )
    }

    func testSimulateLowPowerMode() {
        BatteryService.shared.isLowPowerMode.toggle()
        let active = BatteryService.shared.isLowPowerMode
        HapticService.shared.light()
        triggerNotification(
            title: active ? "Low Power Mode On" : "Standard Power Restored",
            subtitle: active ? "Yellow Battery Active • Background Throttling" : "Normal Background Refresh",
            icon: "battery.25",
            color: active ? .yellow : .green
        )
    }

    // MARK: - Reverse-Engineered System Aperture Methods
    func triggerApplePay(merchant: String = "Apple Park Visitor Center", amount: String = "$14.50") {
        self.applePayMerchant = merchant
        self.applePayAmount = amount
        self.applePayPhase = .ready
        self.setMode(.applePay)
        HapticService.shared.medium()
        expand()
    }

    func authenticateApplePay() {
        guard applePayPhase == .ready else { return }
        applePayPhase = .authenticating
        HapticService.shared.light()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { [weak self] in
            guard let self = self else { return }
            self.applePayPhase = .done
            HapticService.shared.applePayDoneHaptic()

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
                guard let self = self else { return }
                self.collapse()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    if self.mode == .applePay {
                        self.setMode(.media)
                    }
                }
            }
        }
    }

    func triggerAirPodsHUD(left: Int = 96, right: Int = 92, caseBat: Int = 100) {
        self.airPodsLeftBattery = left
        self.airPodsRightBattery = right
        self.airPodsCaseBattery = caseBat
        self.setMode(.airPods)
        HapticService.shared.light()
        expand()
    }

    func triggerRideshareLiveActivity() {
        self.setMode(.rideshare)
        HapticService.shared.medium()
        expand()
    }

    func triggerFlightLiveActivity() {
        self.setMode(.flight)
        HapticService.shared.medium()
        expand()
    }

    func triggerDeliveryLiveActivity() {
        self.setMode(.delivery)
        HapticService.shared.medium()
        expand()
    }

    func toggleScreenRecording() {
        if isScreenRecordingActive {
            isScreenRecordingActive = false
            screenRecordingTimer?.cancel()
            screenRecordingTimer = nil
            HapticService.shared.medium()
            triggerNotification(
                title: "Screen Recording Saved",
                subtitle: "Video saved to Photos app",
                icon: "checkmark.circle.fill",
                color: Color(red: 0.18, green: 0.84, blue: 0.38)
            )
            if mode == .screenRecording {
                setMode(.media)
            }
        } else {
            isScreenRecordingActive = true
            screenRecordingSeconds = 0
            setMode(.screenRecording)
            HapticService.shared.heavy()
            screenRecordingTimer = Timer.publish(every: 1.0, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self = self, self.isScreenRecordingActive else { return }
                    self.screenRecordingSeconds += 1
                }
            expand()
        }
    }

    func toggleMicPrivacy() {
        isMicPrivacyActive.toggle()
        HapticService.shared.light()
        if isMicPrivacyActive {
            triggerNotification(
                title: "Microphone Active",
                subtitle: "DynamicNotch is using your microphone",
                icon: "mic.fill",
                color: .orange
            )
        }
    }

    func toggleCamPrivacy() {
        isCamPrivacyActive.toggle()
        HapticService.shared.light()
        if isCamPrivacyActive {
            triggerNotification(
                title: "Camera Active",
                subtitle: "DynamicNotch is using your camera",
                icon: "camera.fill",
                color: .green
            )
        }
    }

    func tuckToStealth() {
        guard !isIslandHidden else { return }
        HapticService.shared.light()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isIslandHidden = true
            self.isExpanded = false
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func restoreFromStealth() {
        guard isIslandHidden else { return }
        HapticService.shared.medium()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isIslandHidden = false
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func toggleSplitIsland() {
        isSplitIslandActive.toggle()
        isSplitBubbleExpanded = false
        HapticService.shared.medium()
        if isExpanded {
            collapse()
        } else {
            PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
        }
    }

    func setSecondaryActivity(_ activity: SecondaryIslandActivity) {
        self.secondaryActivity = activity
        HapticService.shared.selection()
    }

    func expandSecondaryBubble() {
        isSplitBubbleExpanded = true
        HapticService.shared.medium()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isExpanded = true
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func expandPrimaryPill() {
        isSplitBubbleExpanded = false
        HapticService.shared.medium()
        withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
            self.isExpanded = true
        }
        PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
    }

    func triggerWatchUnlock() {
        HapticService.shared.success()
        triggerNotification(
            title: "Apple Watch",
            subtitle: "Unlocked by Apple Watch",
            icon: "applewatch",
            color: Color(red: 0.18, green: 0.84, blue: 0.38)
        )
    }

    func triggerSIMSwitched() {
        HapticService.shared.medium()
        triggerNotification(
            title: "Cellular Network",
            subtitle: "Switched to Primary 5G Ultra Wideband",
            icon: "antenna.radiowaves.left.and.right",
            color: Color(red: 0.0, green: 0.85, blue: 1.0)
        )
    }

    // MARK: - v8.0 Dynamic Island Apertures & Features
    func triggerAirDropHUD(sender: String = "Sarah's iPhone", count: Int = 4) {
        self.airDropSender = sender
        self.airDropFileCount = count
        self.airDropProgress = 0.0
        self.isAirDropCompleted = false
        setMode(.airDrop)
        HapticService.shared.success()

        // Progressive simulated transfer
        for step in 1...10 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.25) { [weak self] in
                guard let self = self, self.mode == .airDrop else { return }
                withAnimation(.linear(duration: 0.2)) {
                    self.airDropProgress = Double(step) / 10.0
                }
                if step == 10 {
                    self.isAirDropCompleted = true
                    HapticService.shared.success()
                }
            }
        }
    }

    func triggerHotspotHUD() {
        setMode(.hotspot)
        HapticService.shared.medium()
    }

    func triggerCellularHUD() {
        setMode(.cellular)
        HapticService.shared.selection()
    }

    func startPongGame() {
        setMode(.gamePong)
        isPongPlaying = true
        pongScore = 0
        HapticService.shared.medium()
    }

    func hitPongBall() {
        pongScore += 1
        if pongScore > pongHighScore {
            pongHighScore = pongScore
        }
        HapticService.shared.pongHitHaptic()
        withAnimation(.spring(response: 0.15, dampingFraction: 0.35)) {
            self.islandSquishScale = 1.08
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                self?.islandSquishScale = 1.0
            }
        }
    }

    func toggleCompanion() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            companionEnabled.toggle()
        }
        if companionEnabled {
            HapticService.shared.companionPurrHaptic()
        } else {
            HapticService.shared.light()
        }
    }

    func tapCompanion() {
        HapticService.shared.companionPurrHaptic()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.5)) {
            companionAction = (companionAction == .jumping) ? .dancing : .jumping
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            withAnimation {
                self?.companionAction = .walking
            }
        }
    }

    // MARK: - Bubble Touch & Open Active App Engine
    var hasActiveExternalApp: Bool {
        switch mode {
        case .media:
            return NowPlayingService.shared.isPlaying || NowPlayingService.shared.title != "No Music Playing"
        case .call, .timer, .stopwatch, .recording, .navigation, .rideshare, .flight, .delivery, .applePay, .airPods, .airDrop, .hotspot:
            return true
        default:
            return false
        }
    }

    var activeAppName: String {
        switch mode {
        case .media:
            let src = NowPlayingService.shared.sourceAppName
            return (src.isEmpty || src == "Media" || src == "Media Stream") ? "Music" : src
        case .call:
            return "Phone"
        case .timer:
            return "Clock (Timer)"
        case .stopwatch:
            return "Clock (Stopwatch)"
        case .recording:
            return "Voice Memos"
        case .navigation:
            return "Apple Maps"
        case .applePay:
            return "Wallet"
        case .airPods:
            return "Bluetooth"
        case .airDrop:
            return "Photos"
        case .screenRecording:
            return "Photos"
        case .rideshare:
            return rideshareService
        case .delivery:
            return deliveryRestaurant.isEmpty ? "Food Delivery" : deliveryRestaurant
        case .flight:
            return "Flight Tracker"
        case .hotspot:
            return "Hotspot Settings"
        case .cellular:
            return "Cellular Settings"
        case .battery:
            return "Battery Settings"
        default:
            return "App"
        }
    }

    func handleBubbleTouch() {
        switch bubbleTouchAction {
        case .openApp:
            openActiveApp()

        case .expandOnly:
            toggleExpanded()

        case .smartAdaptive:
            if hasActiveExternalApp {
                openActiveApp()
            } else {
                toggleExpanded()
            }
        }
    }

    func handleMajorPillTouch() {
        switch bubbleTouchAction {
        case .openApp:
            openActiveApp()

        case .expandOnly:
            expandPrimaryPill()

        case .smartAdaptive:
            if hasActiveExternalApp {
                openActiveApp()
            } else {
                expandPrimaryPill()
            }
        }
    }

    func handleOrbitBubbleTouch() {
        switch bubbleTouchAction {
        case .openApp:
            openSecondaryActiveApp()

        case .expandOnly:
            expandSecondaryBubble()

        case .smartAdaptive:
            if hasActiveSecondaryApp {
                openSecondaryActiveApp()
            } else {
                expandSecondaryBubble()
            }
        }
    }

    var hasActiveSecondaryApp: Bool {
        switch secondaryActivity {
        case .timer, .stopwatch, .recording, .hotspot:
            return true
        default:
            return false
        }
    }

    func openActiveApp() {
        HapticService.shared.medium()

        switch mode {
        case .media:
            openMediaApp()

        case .call:
            launchAppURL("mobilephone://", fallback: "tel://")

        case .timer:
            launchAppURL("clock-timer://", fallback: "clock://")

        case .stopwatch:
            launchAppURL("clock-stopwatch://", fallback: "clock://")

        case .recording:
            launchAppURL("voicememos://")

        case .navigation:
            launchAppURL("maps://")

        case .applePay:
            launchAppURL("shoebox://")

        case .airPods:
            launchAppURL("App-Prefs:root=Bluetooth")

        case .airDrop:
            launchAppURL("photos-redirect://")

        case .screenRecording:
            launchAppURL("photos-redirect://")

        case .rideshare:
            launchAppURL("uber://", fallback: "lyft://")

        case .delivery:
            launchAppURL("doordash://", fallback: "ubereats://")

        case .flight:
            launchAppURL("flighty://")

        case .hotspot:
            launchAppURL("App-Prefs:root=INTERNET_TETHERING", fallback: "prefs:root=INTERNET_TETHERING")

        case .cellular:
            launchAppURL("App-Prefs:root=MOBILE_DATA_SETTINGS_ID")

        case .battery:
            launchAppURL("App-Prefs:root=BATTERY")

        case .blank, .flashlight, .silent, .sports, .gamePong:
            // For internal modes without external apps, expand the island in-place
            withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
                self.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
        }
    }

    func openSecondaryActiveApp() {
        HapticService.shared.medium()

        switch secondaryActivity {
        case .timer:
            launchAppURL("clock-timer://", fallback: "clock://")

        case .stopwatch:
            launchAppURL("clock-stopwatch://", fallback: "clock://")

        case .recording:
            launchAppURL("voicememos://")

        case .hotspot:
            launchAppURL("App-Prefs:root=INTERNET_TETHERING", fallback: "prefs:root=INTERNET_TETHERING")

        case .sports, .battery, .micPrivacy, .cameraPrivacy, .navigation:
            withAnimation(.spring(response: animationProfile.response, dampingFraction: animationProfile.damping)) {
                self.isSplitBubbleExpanded = true
                self.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(width: islandWidth, height: islandHeight)
        }
    }

    func openMediaApp() {
        let app = NowPlayingService.shared.sourceAppName.lowercased()
        if app.contains("spotify") {
            launchAppURL("spotify://")
        } else if app.contains("youtube music") {
            launchAppURL("youtubemusic://", fallback: "youtube://")
        } else if app.contains("youtube") {
            launchAppURL("youtube://")
        } else if app.contains("soundcloud") {
            launchAppURL("soundcloud://")
        } else if app.contains("stremio") {
            launchAppURL("stremio://")
        } else if app.contains("podcast") {
            launchAppURL("podcasts://")
        } else if app.contains("tidal") {
            launchAppURL("tidal://")
        } else if app.contains("deezer") {
            launchAppURL("deezer://")
        } else if app.contains("music") || app.contains("apple") {
            launchAppURL("music://")
        } else {
            // General media fallback
            launchAppURL("music://", fallback: "spotify://")
        }
    }

    func launchAppURL(_ primary: String, fallback: String? = nil) {
        if let url = URL(string: primary) {
            UIApplication.shared.open(url, options: [:]) { success in
                if !success, let fb = fallback, let fbUrl = URL(string: fb) {
                    UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
                }
            }
        } else if let fb = fallback, let fbUrl = URL(string: fb) {
            UIApplication.shared.open(fbUrl, options: [:], completionHandler: nil)
        }
    }

    func dismissPiPExpansion() {
        collapse()
        withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
            self.isExpandedViaPiPTap = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            PiPIslandManager.shared.start()
        }
    }
}
