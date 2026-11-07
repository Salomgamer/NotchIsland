import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared
    @ObservedObject var nowPlaying = NowPlayingService.shared
    @ObservedObject var battery = BatteryService.shared
    @ObservedObject var bgEngine = BackgroundEngine.shared
    @ObservedObject var torch = TorchService.shared

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header Bar
                    headerBar

                    // Live Interactive Preview & Notch Guide
                    previewSection

                    // Primary Launch / Dismiss Button
                    launchButton

                    // Connected Audio Route & Flashlight Quick Bar
                    quickStatusSection

                    // Activity Mode Switcher (All 6 features)
                    activitySelector

                    // Mode-Specific Interactive Controls
                    modeInteractiveSection

                    // Accent Theme Picker
                    themeSection

                    // Island Background Style Picker
                    backgroundSection

                    // Gesture Actions (Double-Tap & Long-Press)
                    gesturesSection

                    // Device Notch Sizing Presets
                    notchPresetsSection

                    // Notch Precision Calibrator
                    notchCalibratorSection

                    // Lock Under Notch Instructions
                    notchPlacementGuide

                    // System Permissions & Diagnostics
                    permissionsSection
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            nowPlaying.checkPermissions()
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Dynamic Notch")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Dynamic Island 2.0 • iPhone 11")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            if battery.isLowPowerMode {
                HStack(spacing: 4) {
                    Image(systemName: "battery.100.bolt")
                    Text("Low Power")
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.yellow)
                .clipShape(Capsule())
            }

            // Always-On Engine Indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(state.theme.color)
                    .frame(width: 8, height: 8)
                Text("Always-On")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(white: 0.12))
            .clipShape(Capsule())
        }
        .padding(.top, 10)
    }

    // MARK: - Live Preview Section
    private var previewSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(white: 0.09))
                .frame(height: state.isExpanded ? 140 : 125)

            VStack(spacing: 0) {
                // Physical Notch Silhouette
                Path { path in
                    path.move(to: CGPoint(x: 100, y: 0))
                    path.addLine(to: CGPoint(x: 125, y: 24))
                    path.addLine(to: CGPoint(x: 275, y: 24))
                    path.addLine(to: CGPoint(x: 300, y: 0))
                }
                .fill(Color.black)
                .frame(height: 24)

                Spacer()

                // Floating Island in Preview & Active PiP Anchor
                ZStack {
                    PiPAnchorRepresentable()
                        .frame(width: state.islandWidth, height: state.islandHeight)
                        .allowsHitTesting(false)

                    FloatingIslandView(state: state)
                        .frame(width: state.islandWidth, height: state.islandHeight)
                        .clipShape(RoundedRectangle(cornerRadius: state.isExpanded ? 24 : 18, style: .continuous))
                        .shadow(color: .black.opacity(0.7), radius: 10, x: 0, y: 3)
                }

                Spacer()
            }
        }
    }

    // MARK: - Launch Button
    private var launchButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            pip.toggle()
        }) {
            HStack(spacing: 10) {
                Image(systemName: pip.isPiPActive ? "stop.fill" : "play.fill")
                    .font(.system(size: 17, weight: .bold))
                Text(pip.isPiPActive ? "Dismiss Floating Island" : "Launch Dynamic Notch 2.0")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(pip.isPiPActive ? Color.red : state.theme.color)
            .clipShape(Capsule())
            .shadow(color: (pip.isPiPActive ? Color.red : state.theme.color).opacity(0.35), radius: 10, x: 0, y: 4)
        }
    }

    // MARK: - Quick Status & Accessories
    private var quickStatusSection: some View {
        HStack(spacing: 10) {
            // Audio Destination / AirPods Card
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(nowPlaying.currentRouteType.isExternalOrHeadphones ? Color.green.opacity(0.25) : Color.white.opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: nowPlaying.currentRouteType.iconName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(nowPlaying.currentRouteType.isExternalOrHeadphones ? .green : .white)
                }

                VStack(alignment: .leading, spacing: 1.5) {
                    Text(nowPlaying.currentRouteName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(nowPlaying.currentRouteType.rawValue)
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(white: 0.10))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Flashlight Quick Toggle
            Button(action: {
                torch.toggleTorch()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: torch.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text(torch.isTorchOn ? "On" : "Torch")
                        .font(.system(size: 11.5, weight: .bold))
                }
                .foregroundColor(torch.isTorchOn ? .black : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(torch.isTorchOn ? Color.yellow : Color(white: 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: torch.isTorchOn ? Color.yellow.opacity(0.4) : .clear, radius: 8)
            }
        }
    }

    // MARK: - Activity Mode Selector
    private var activitySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("DYNAMIC ACTIVITIES")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.gray.opacity(0.8))
                    .kerning(1.2)
                Spacer()
                HStack(spacing: 4) {
                    Text("Auto-Switch")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(state.autoSwitchModes ? state.theme.color : .gray)
                    Toggle("", isOn: $state.autoSwitchModes)
                        .labelsHidden()
                        .onChange(of: state.autoSwitchModes) { val in
                            if val {
                                state.evaluateActiveMode()
                            }
                        }
                }
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(IslandMode.allCases, id: \.self) { mode in
                    Button(action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        state.setMode(mode)
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: iconForMode(mode))
                                .font(.system(size: 12, weight: .semibold))
                            Text(mode.rawValue)
                                .font(.system(size: 11.5, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(state.mode == mode ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(state.mode == mode ? state.theme.color : Color(white: 0.13))
                        )
                    }
                }
            }
        }
    }

    // MARK: - Mode Interactive Section
    private var modeInteractiveSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            switch state.mode {
            case .blank:
                blankControls

            case .media:
                mediaControls

            case .call:
                callControls

            case .timer:
                timerControls

            case .stopwatch:
                stopwatchControls

            case .battery:
                batteryControls

            case .silent:
                silentControls
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Blank Controls
    private var blankControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "eye.slash.fill")
                    .foregroundColor(state.theme.color)
                Text("Blank / Stealth Notch Mode")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("Active Stealth")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }

            Text("Presents a pure black silhouette that blends invisibly into the physical iPhone 11 notch. Dynamic Notch remains completely silent until a media stream starts, a phone call connects, or the charger is plugged in.")
                .font(.system(size: 10.5))
                .foregroundColor(.gray)

            HStack {
                Button(action: {
                    state.setMode(.media)
                }) {
                    Text("Switch to Music & Battery")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(state.theme.color)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.triggerNotification(title: "Stealth Island", subtitle: "Tap or play audio to activate")
                }) {
                    Text("Test Ping")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.16))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Media Controls
    private var mediaControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(state.theme.color)
                Text("Universal Media (Spotify, YouTube, Safari, Stremio)")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(nowPlaying.isPlaying ? "Playing" : "Standby")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(nowPlaying.isPlaying ? .green : .gray)
            }

            Text("Song: \(state.mediaTitle)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

            HStack(spacing: 6) {
                Text("Artist: \(state.mediaArtist)")
                    .font(.system(size: 10.5))
                    .foregroundColor(.gray)

                Text("• App: \(nowPlaying.sourceAppName)")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(state.theme.color)
            }

            Divider().background(Color.white.opacity(0.1))

            // Playback Remote Controls
            HStack(spacing: 20) {
                Button(action: { nowPlaying.previousTrack() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color(white: 0.16))
                        .clipShape(Circle())
                }

                Button(action: { nowPlaying.togglePlayPause() }) {
                    Image(systemName: nowPlaying.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                        .padding(12)
                        .background(state.theme.color)
                        .clipShape(Circle())
                }

                Button(action: { nowPlaying.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(9)
                        .background(Color(white: 0.16))
                        .clipShape(Circle())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 2)

            HStack {
                Button(action: {
                    nowPlaying.requestAllPermissions()
                }) {
                    Text("Sync Media")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(state.theme.color)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.triggerNotification(title: "Notification Pop", subtitle: "Auto-expanded Dynamic Island!")
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.badge.fill")
                        Text("Test Pop")
                    }
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.18))
                    .clipShape(Capsule())
                }

                Button(action: {
                    state.triggerNotification(
                        title: "AirPods Pro Connected",
                        subtitle: "High-Fidelity Stereo Audio",
                        icon: "airpodspro",
                        color: Color(red: 0.18, green: 0.84, blue: 0.38)
                    )
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "airpodspro")
                        Text("AirPods")
                    }
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.18))
                    .clipShape(Capsule())
                }

                Button(action: {
                    let newVol = min(1.0, state.systemVolume + 0.1)
                    state.showVolumeHUD(level: newVol)
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Vol HUD")
                    }
                    .font(.system(size: 10.5, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.18))
                    .clipShape(Capsule())
                }

                Spacer()

                Button(action: {
                    state.toggleExpanded()
                }) {
                    Text(state.isExpanded ? "Collapse" : "Expand")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.18))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Call Controls
    private var callControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "phone.fill")
                    .foregroundColor(.green)
                Text("Call HUD Simulator")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            Text("Simulate an incoming phone call or connected conversation inside the Dynamic Island.")
                .font(.system(size: 10.5))
                .foregroundColor(.gray)

            HStack(spacing: 8) {
                Button(action: {
                    state.callerName = "Incoming Call"
                    state.callerSubtitle = "Mobile • John Appleseed"
                    state.isCallActive = false
                }) {
                    Text("Trigger Call")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.answerCall()
                }) {
                    Text("Answer")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.declineCall()
                }) {
                    Text("End")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red)
                        .clipShape(Capsule())
                }

                if state.isCallActive {
                    Button(action: { state.toggleCallMute() }) {
                        Image(systemName: state.isCallMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 11))
                            .foregroundColor(state.isCallMuted ? .red : .white)
                            .padding(6)
                            .background(Color(white: 0.16))
                            .clipShape(Circle())
                    }

                    Button(action: { state.toggleSpeaker() }) {
                        Image(systemName: state.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill")
                            .font(.system(size: 11))
                            .foregroundColor(state.isSpeakerOn ? .green : .white)
                            .padding(6)
                            .background(Color(white: 0.16))
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    // MARK: - Timer Controls
    private var timerControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                Text("Focus & Pomodoro Timer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.timerFormatted)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }

            HStack(spacing: 6) {
                ForEach([1, 5, 15, 25, 45], id: \.self) { mins in
                    Button(action: {
                        state.setTimerPreset(minutes: mins)
                    }) {
                        Text("\(mins)m")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(white: 0.16))
                            .clipShape(Capsule())
                    }
                }

                Button(action: {
                    state.isTimerRunning.toggle()
                }) {
                    Image(systemName: state.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
        }
    }

    // MARK: - Stopwatch Controls
    private var stopwatchControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "stopwatch.fill")
                    .foregroundColor(state.theme.color)
                Text("Precision Stopwatch")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.stopwatchFormatted)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(state.theme.color)
            }

            HStack(spacing: 8) {
                Button(action: {
                    if state.isStopwatchRunning {
                        state.isStopwatchRunning = false
                    } else {
                        state.startStopwatch()
                    }
                }) {
                    Text(state.isStopwatchRunning ? "Pause" : "Start")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(state.theme.color)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.recordLap()
                }) {
                    Text("Lap")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.16))
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.resetStopwatch()
                }) {
                    Text("Reset")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.16))
                        .clipShape(Capsule())
                }
            }

            if !state.stopwatchLaps.isEmpty {
                VStack(alignment: .leading, spacing: 3) {
                    ForEach(state.stopwatchLaps.prefix(4), id: \.self) { lap in
                        Text(lap)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    // MARK: - Battery Controls
    private var batteryControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundColor(.green)
                Text("IOKit Hardware Battery Monitor")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(state.batteryPercentage)%")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }

            Text("Reading exact 1% integer capacity directly from kernel IOKit power source registry (bypassing standard 5% quantization).")
                .font(.system(size: 10.5))
                .foregroundColor(.gray)

            Button(action: {
                BatteryService.shared.updateBattery()
            }) {
                Text("Force Refresh Battery")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(white: 0.16))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Silent HUD Controls
    private var silentControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: state.isSilentOn ? "bell.slash.fill" : "bell.fill")
                    .foregroundColor(state.isSilentOn ? .red : .green)
                Text("Silent / Ringer Switch HUD")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.isSilentOn ? "SILENT" : "RING")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(state.isSilentOn ? .red : .green)
            }

            Text("Shows the native iOS 17 style Silent / Ring banner at the top of your screen.")
                .font(.system(size: 10.5))
                .foregroundColor(.gray)

            Button(action: {
                state.toggleSilentMode()
            }) {
                Text(state.isSilentOn ? "Switch to Ring Mode" : "Switch to Silent Mode")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(state.isSilentOn ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Theme Picker Section
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ACCENT THEME")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.gray.opacity(0.8))
                .kerning(1.2)
                .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AccentTheme.allCases, id: \.self) { theme in
                        Button(action: {
                            HapticService.shared.selection()
                            state.theme = theme
                        }) {
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 10, height: 10)
                                Text(theme.rawValue)
                                    .font(.system(size: 11.5, weight: .semibold))
                            }
                            .foregroundColor(state.theme == theme ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(state.theme == theme ? theme.color : Color(white: 0.13))
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Background Customization Section
    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "paintpalette.fill")
                    .foregroundColor(state.theme.color)
                Text("ISLAND BACKGROUND STYLE")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.2)
                Spacer()
                Text(state.backgroundStyle.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.theme.color)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(IslandBackgroundStyle.allCases) { bgStyle in
                        Button(action: {
                            HapticService.shared.selection()
                            state.backgroundStyle = bgStyle
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: bgStyle.icon)
                                    .font(.system(size: 11, weight: .bold))
                                Text(bgStyle.rawValue)
                                    .font(.system(size: 11.5, weight: .semibold))
                            }
                            .foregroundColor(state.backgroundStyle == bgStyle ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(state.backgroundStyle == bgStyle ? state.theme.color : Color(white: 0.13))
                            )
                        }
                    }
                }
            }

            // Opacity & Glass Slider
            HStack {
                Text("Opacity: \(Int(state.backgroundOpacity * 100))%")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Slider(value: $state.backgroundOpacity, in: 0.4...1.0, step: 0.05)
                    .frame(width: 180)
            }
            .padding(.top, 2)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Gestures & Interactions Section
    private var gesturesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(state.theme.color)
                Text("GESTURE ACTIONS")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.2)
                Spacer()
                Text("Double-Tap: \(state.doubleTapAction.rawValue)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.theme.color)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(DoubleTapAction.allCases) { action in
                        Button(action: {
                            HapticService.shared.selection()
                            state.doubleTapAction = action
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: action.icon)
                                    .font(.system(size: 11, weight: .bold))
                                Text(action.rawValue)
                                    .font(.system(size: 11.5, weight: .semibold))
                            }
                            .foregroundColor(state.doubleTapAction == action ? .black : .white)
                            .padding(.horizontal, 11)
                            .padding(.vertical, 7)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(state.doubleTapAction == action ? state.theme.color : Color(white: 0.13))
                            )
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("• Single Tap: Expand / Collapse Island")
                    Text("• Double Tap: \(state.doubleTapAction.rawValue)")
                    Text("• Long Press: Cycle Activities (Music, Timer, Call, etc.)")
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Device Notch Presets
    private var notchPresetsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("DEVICE NOTCH PRESETS")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.gray.opacity(0.8))
                    .kerning(1.2)
                Spacer()
                Text(state.selectedPreset.badge)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.theme.color)
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(DeviceNotchPreset.allCases) { preset in
                    Button(action: {
                        state.applyPreset(preset)
                    }) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(state.selectedPreset == preset ? state.theme.color : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(preset.rawValue)
                                    .font(.system(size: 11, weight: .bold))
                                Text(preset.badge)
                                    .font(.system(size: 9.5))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(state.selectedPreset == preset ? Color(white: 0.18) : Color(white: 0.11))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(state.selectedPreset == preset ? state.theme.color.opacity(0.8) : Color.clear, lineWidth: 1)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Notch Precision Calibrator
    private var notchCalibratorSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(state.theme.color)
                Text("PIXEL CALIBRATOR (CUSTOM NOTCH FIT)")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Toggle("", isOn: $state.useCustomSize)
                    .labelsHidden()
                    .onChange(of: state.useCustomSize) { _ in
                        HapticService.shared.selection()
                        PiPIslandManager.shared.updateSize(width: state.islandWidth, height: state.islandHeight)
                    }
            }

            if state.useCustomSize {
                VStack(spacing: 8) {
                    HStack {
                        Text("Width: \(Int(state.customWidth))pt")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Slider(value: $state.customWidth, in: 130...220, step: 2)
                            .frame(width: 180)
                            .onChange(of: state.customWidth) { w in
                                state.updateCustomCalibration(width: w, height: state.customHeight, cornerRadius: state.customCornerRadius)
                            }
                    }

                    HStack {
                        Text("Height: \(Int(state.customHeight))pt")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Slider(value: $state.customHeight, in: 28...46, step: 2)
                            .frame(width: 180)
                            .onChange(of: state.customHeight) { h in
                                state.updateCustomCalibration(width: state.customWidth, height: h, cornerRadius: state.customCornerRadius)
                            }
                    }

                    HStack {
                        Text("Radius: \(Int(state.customCornerRadius))pt")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                        Slider(value: $state.customCornerRadius, in: 12...24, step: 1)
                            .frame(width: 180)
                            .onChange(of: state.customCornerRadius) { r in
                                state.updateCustomCalibration(width: state.customWidth, height: state.customHeight, cornerRadius: r)
                            }
                    }

                    Button(action: {
                        HapticService.shared.light()
                        state.updateCustomCalibration(width: 156, height: 36, cornerRadius: 18)
                    }) {
                        Text("Reset to iPhone 11 Standard (156×36)")
                            .font(.system(size: 10.5, weight: .semibold))
                            .foregroundColor(state.theme.color)
                            .padding(.vertical, 4)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Notch Placement Guide
    private var notchPlacementGuide: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 20))
                .foregroundColor(state.theme.color)

            VStack(alignment: .leading, spacing: 2) {
                Text("Lock Under Notch (iPhone 11)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text("Tap Launch, swipe to Home Screen, and drag the floating island to the top center. It locks flush under the physical notch.")
                    .font(.system(size: 10.5))
                    .foregroundColor(.gray)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Permissions & Accuracy Diagnostics
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundColor(state.theme.color)
                Text("SYSTEM PERMISSIONS & ACCURACY")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if nowPlaying.hasMediaPermission {
                    Text("Synced ✓")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
            }

            Button(action: {
                nowPlaying.requestAllPermissions()
            }) {
                HStack {
                    Image(systemName: nowPlaying.hasMediaPermission ? "checkmark.circle.fill" : "lock.open.fill")
                        .foregroundColor(nowPlaying.hasMediaPermission ? .green : .white)
                    Text(nowPlaying.hasMediaPermission ? "Permissions Granted & Synchronized" : "Grant Music & System Permissions")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 9)
                .padding(.horizontal, 12)
                .background(Color(white: 0.13))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Spotify / EeveeSpotify iOS Sync:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Text("Dynamic Notch streams directly from iOS system media routing and hardware audio session. No broadcast settings needed.")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func iconForMode(_ mode: IslandMode) -> String {
        return state.iconForMode(mode)
    }
}

// MARK: - Active PiP Source Anchor
struct PiPAnchorRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        DispatchQueue.main.async {
            PiPIslandManager.shared.attach(to: view)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

