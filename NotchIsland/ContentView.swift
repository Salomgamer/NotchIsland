import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared
    @ObservedObject var nowPlaying = NowPlayingService.shared
    @ObservedObject var battery = BatteryService.shared
    @ObservedObject var bgEngine = BackgroundEngine.shared
    @ObservedObject var torch = TorchService.shared
    @State private var showingWhatsNew: Bool = false

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

                    // Interactive Test Lab & Dynamic Island Notification Simulator
                    dynamicIslandTestLab

                    // Activity Mode Switcher (All 6 features)
                    activitySelector

                    // Mode-Specific Interactive Controls
                    modeInteractiveSection

                    // Accent Theme Picker
                    themeSection

                    // Island Background Style Picker
                    backgroundSection

                    // Audio Visualizer Style Picker
                    visualizerSection

                    // Gesture Actions (Double-Tap & Long-Press)
                    gesturesSection

                    // Device Notch Sizing Presets
                    notchPresetsSection

                    // Notch Precision Calibrator
                    notchCalibratorSection

                    // Lock Under Notch Instructions
                    notchPlacementGuide

                    // Signature Haptics Showcase
                    hapticsShowcaseSection

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
        .sheet(isPresented: $showingWhatsNew) {
            WhatsNewView(isPresented: $showingWhatsNew, themeColor: state.theme.color)
        }
    }

    // MARK: - Header Bar
    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Dynamic Notch")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("Dynamic Island 4.7 • iPhone 11")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button(action: {
                HapticService.shared.selection()
                showingWhatsNew = true
            }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 21))
                    .foregroundColor(state.theme.color)
            }

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

                Text("Tap pill to expand / collapse in place")
                    .font(.system(size: 9.5, weight: .medium))
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.bottom, 6)
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
                Text(pip.isPiPActive ? "Dismiss Floating Island" : "Launch Dynamic Notch 3.0")
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
        VStack(spacing: 8) {
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
                    HStack(spacing: 5) {
                        Image(systemName: torch.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(torch.isTorchOn ? "On" : "Torch")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(torch.isTorchOn ? .black : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(torch.isTorchOn ? Color.yellow : Color(white: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: torch.isTorchOn ? Color.yellow.opacity(0.4) : .clear, radius: 8)
                }

                // SOS Strobe Emergency Toggle
                Button(action: {
                    torch.toggleSOS()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 12, weight: .bold))
                        Text(torch.isSOSActive ? "SOS" : "SOS")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(torch.isSOSActive ? .white : .gray)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(torch.isSOSActive ? Color.red : Color(white: 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: torch.isSOSActive ? Color.red.opacity(0.5) : .clear, radius: 8)
                }
            }

            if torch.isTorchOn && !torch.isSOSActive {
                HStack(spacing: 6) {
                    Text("Torch Level:")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.gray)
                    ForEach([0.25, 0.50, 0.75, 1.0], id: \.self) { lvl in
                        Button(action: {
                            torch.setTorchLevel(Float(lvl))
                        }) {
                            Text("\(Int(lvl * 100))%")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(torch.torchLevel == Float(lvl) ? .black : .white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(torch.torchLevel == Float(lvl) ? Color.yellow : Color(white: 0.16))
                                .clipShape(Capsule())
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
            }
        }
    }

    // MARK: - Dynamic Island Notification Test Lab
    private var dynamicIslandTestLab: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundColor(state.theme.color)
                Text("DYNAMIC ISLAND TEST LAB")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.2)
                Spacer()
                Text("Tap to Trigger")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                testTriggerButton(title: "⚡ Fast Charge", color: .green) {
                    state.testSimulateChargerPlug()
                }

                testTriggerButton(title: "🎧 AirPods Pro", color: state.theme.color) {
                    state.testSimulateAirPodsConnect()
                }

                testTriggerButton(title: "🪫 Low Battery (10%)", color: .red) {
                    state.testSimulateLowBattery()
                }

                testTriggerButton(title: "🔋 Full Charge (100%)", color: .green) {
                    state.testSimulateFullCharge()
                }

                testTriggerButton(title: "🌡️ Device Hot (43°C)", color: .orange) {
                    state.testSimulateThermal()
                }

                testTriggerButton(title: "⏱️ Focus Finished", color: .orange) {
                    state.testSimulateTimerFinish()
                }

                testTriggerButton(title: "📋 Clipboard HUD", color: .cyan) {
                    state.testSimulateClipboard()
                }

                testTriggerButton(title: "🔔 Silent / Ring HUD", color: state.isSilentOn ? .green : .red) {
                    state.toggleSilentMode()
                }

                testTriggerButton(title: "🔊 Volume HUD (85%)", color: .white) {
                    state.showVolumeHUD(level: 0.85)
                }

                testTriggerButton(title: "📞 Incoming Call", color: .green) {
                    state.testSimulateIncomingCall()
                }

                testTriggerButton(title: "👤 Face ID Verified", color: .green) {
                    state.testSimulateFaceID()
                }

                testTriggerButton(title: "📡 AirDrop File", color: .blue) {
                    state.testSimulateAirDrop()
                }

                testTriggerButton(title: "📶 Personal Hotspot", color: .green) {
                    state.testSimulateHotspot()
                }

                testTriggerButton(title: "🎙️ Voice Memo", color: .red) {
                    state.testSimulateVoiceMemo()
                }

                testTriggerButton(title: "🗺️ Turn Right (300ft)", color: .green) {
                    state.setMode(.navigation)
                    state.triggerNotification(
                        title: "Turn Right in 300 ft",
                        subtitle: "Apple Park Way • ETA 12:45 PM",
                        icon: "arrow.turn.up.right",
                        color: Color(red: 0.18, green: 0.84, blue: 0.38)
                    )
                }

                testTriggerButton(title: "⚽ RMA 2 - 1 FCB", color: .green) {
                    state.setMode(.sports)
                    state.triggerNotification(
                        title: "GOAL! Real Madrid",
                        subtitle: "RMA 2 - 1 FCB • Bellingham 67'",
                        icon: "sportscourt.fill",
                        color: .green
                    )
                }
            }
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func testTriggerButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(white: 0.13))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(color.opacity(0.35), lineWidth: 1)
            )
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
                HStack(spacing: 7) {
                    HStack(spacing: 3) {
                        Text("Auto")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(state.autoSwitchModes ? state.theme.color : .gray)
                        Toggle("", isOn: $state.autoSwitchModes)
                            .labelsHidden()
                            .onChange(of: state.autoSwitchModes) { val in
                                if val {
                                    state.evaluateActiveMode()
                                }
                            }
                    }

                    HStack(spacing: 3) {
                        Text("Dual")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(state.dualActivityEnabled ? state.theme.color : .gray)
                        Toggle("", isOn: $state.dualActivityEnabled)
                            .labelsHidden()
                    }

                    HStack(spacing: 3) {
                        Text("Clip")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(state.clipboardHUDEnabled ? state.theme.color : .gray)
                        Toggle("", isOn: $state.clipboardHUDEnabled)
                            .labelsHidden()
                    }
                }
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
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

            case .navigation:
                navigationControls

            case .sports:
                sportsControls

            case .recording:
                recordingControls

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

    // MARK: - Navigation Controls (Apple Maps)
    private var navigationControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "arrow.turn.up.right")
                    .foregroundColor(Color(red: 0.18, green: 0.84, blue: 0.38))
                Text("Apple Maps Turn-by-Turn Navigation")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("ACTIVE ROUTE")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.green)
            }

            Text("\(state.navInstruction) • \(state.navDistance)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Button(action: {
                    state.navInstruction = "Turn Right onto Apple Park Way"
                    state.navDistance = "In 300 ft"
                    state.triggerNotification(
                        title: "Turn Right in 300 ft",
                        subtitle: "Apple Park Way • ETA 12:45 PM",
                        icon: "arrow.turn.up.right",
                        color: Color(red: 0.18, green: 0.84, blue: 0.38)
                    )
                }) {
                    Text("Turn Right")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(red: 0.18, green: 0.84, blue: 0.38))
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.navInstruction = "Merge Left onto I-280 North"
                    state.navDistance = "In 1.2 mi"
                    state.triggerNotification(
                        title: "Merge Left in 1.2 mi",
                        subtitle: "I-280 North • San Francisco",
                        icon: "arrow.triangle.merge",
                        color: Color(red: 0.18, green: 0.84, blue: 0.38)
                    )
                }) {
                    Text("Highway Merge")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.16))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Live Sports Controls
    private var sportsControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sportscourt.fill")
                    .foregroundColor(.green)
                Text("Live Sports Scoreboard")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("LIVE MATCH")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.green)
            }

            Text("\(state.sportsLeague): \(state.sportsHomeTeam) \(state.sportsHomeScore) - \(state.sportsAwayScore) \(state.sportsAwayTeam) (\(state.sportsMatchTime))")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Button(action: {
                    state.sportsHomeScore += 1
                    HapticService.shared.success()
                    state.triggerNotification(
                        title: "GOAL! Real Madrid",
                        subtitle: "\(state.sportsHomeTeam) \(state.sportsHomeScore) - \(state.sportsAwayScore) \(state.sportsAwayTeam) (Jude 82')",
                        icon: "sportscourt.fill",
                        color: .green
                    )
                }) {
                    Text("+1 Goal Home")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                }

                Button(action: {
                    state.sportsAwayScore += 1
                    HapticService.shared.warning()
                    state.triggerNotification(
                        title: "GOAL! Barcelona",
                        subtitle: "\(state.sportsHomeTeam) \(state.sportsHomeScore) - \(state.sportsAwayScore) \(state.sportsAwayTeam) (Lewandowski 85')",
                        icon: "sportscourt.fill",
                        color: .yellow
                    )
                }) {
                    Text("+1 Goal Away")
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(white: 0.16))
                        .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Voice Memo Controls
    private var recordingControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "record.circle.fill")
                    .foregroundColor(.red)
                Text("Voice Memo Recording")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(state.isRecordingActive ? "RECORDING" : "STANDBY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.isRecordingActive ? .red : .gray)
            }

            Text("Duration: \(state.recordingTimeFormatted) • Stereo 48kHz Linear PCM")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

            HStack {
                Button(action: {
                    state.toggleRecording()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: state.isRecordingActive ? "stop.fill" : "record.circle")
                        Text(state.isRecordingActive ? "Stop Recording" : "Start Voice Memo")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.red)
                    .clipShape(Capsule())
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

            if let health = battery.batteryHealthPercentage {
                HStack(spacing: 5) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.pink)
                    Text("Battery Health: \(health)% (Maximum Capacity)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 2)
            }

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

    // MARK: - Audio Visualizer Style Section
    private var visualizerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundColor(state.theme.color)
                Text("AUDIO VISUALIZER STYLE")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.2)
                Spacer()
                Text(state.visualizerStyle.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(state.theme.color)
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(VisualizerStyle.allCases) { style in
                    Button(action: {
                        HapticService.shared.selection()
                        state.visualizerStyle = style
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: style.icon)
                                .font(.system(size: 11, weight: .bold))
                            Text(style.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                            Spacer()
                        }
                        .foregroundColor(state.visualizerStyle == style ? .black : .white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(state.visualizerStyle == style ? state.theme.color : Color(white: 0.13))
                        )
                    }
                }
            }

            // Dynamics / Response Speed
            HStack(spacing: 8) {
                Text("Dynamics:")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.gray)

                ForEach(VisualizerSpeed.allCases) { spd in
                    Button(action: {
                        HapticService.shared.selection()
                        state.visualizerSpeed = spd
                    }) {
                        Text(spd.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(state.visualizerSpeed == spd ? .black : .white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(state.visualizerSpeed == spd ? state.theme.color : Color(white: 0.15))
                            .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .padding(.top, 2)

            // Palette / Color Mode
            HStack(spacing: 8) {
                Text("Palette:")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.gray)

                ForEach(VisualizerColorMode.allCases) { colMode in
                    Button(action: {
                        HapticService.shared.selection()
                        state.visualizerColorMode = colMode
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: colMode.icon)
                                .font(.system(size: 9))
                            Text(colMode.rawValue)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundColor(state.visualizerColorMode == colMode ? .black : .white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(state.visualizerColorMode == colMode ? state.theme.color : Color(white: 0.15))
                        .clipShape(Capsule())
                    }
                }
                Spacer()
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

            // Animation Spring Physics Profile
            HStack(spacing: 8) {
                Text("Physics:")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.gray)

                ForEach(IslandAnimationProfile.allCases) { profile in
                    Button(action: {
                        HapticService.shared.selection()
                        state.animationProfile = profile
                    }) {
                        Text(profile.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(state.animationProfile == profile ? .black : .white)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(state.animationProfile == profile ? state.theme.color : Color(white: 0.15))
                            .clipShape(Capsule())
                    }
                }
                Spacer()
            }
            .padding(.top, 2)

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

    // MARK: - Signature Haptics Showcase
    private var hapticsShowcaseSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(state.theme.color)
                Text("APPLE TAPTIC FEEDBACK")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .kerning(1.2)
                Spacer()
                Text("Taptic Engine")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                Button(action: { HapticService.shared.selection() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.point.up.left.fill")
                            .font(.system(size: 11))
                        Text("Selection")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Button(action: { HapticService.shared.medium() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                            .font(.system(size: 11))
                        Text("Expand Spring")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Button(action: { HapticService.shared.chargeHaptic() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 11))
                        Text("Charge Surge")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }

                Button(action: { HapticService.shared.doubleTapHaptic() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 11))
                        Text("Double-Tap")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.13))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
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

// MARK: - What's New in Dynamic Notch 4.7 Sheet
struct WhatsNewView: View {
    @Binding var isPresented: Bool
    let themeColor: Color

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.06).ignoresSafeArea()

            VStack(spacing: 16) {
                // Header
                VStack(spacing: 5) {
                    Text("What's New in")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Dynamic Notch 4.7")
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.top, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        featureRow(
                            icon: "bell.slash.fill",
                            color: .red,
                            title: "Hardware Silent Switch Haptics",
                            desc: "Authentic double-pulse haptic vibration replicating Apple's physical mute switch behavior when toggling Silent Mode."
                        )

                        featureRow(
                            icon: "speaker.wave.2.fill",
                            color: themeColor,
                            title: "Discrete Volume Steppers & Mute",
                            desc: "Quick +/- 5% volume buttons and one-tap mute directly integrated into the expanded media controls."
                        )

                        featureRow(
                            icon: "hand.tap.fill",
                            color: .purple,
                            title: "Expanded Double-Tap Actions",
                            desc: "Double-tap on the collapsed notch now supports instant Mute toggle and Stealth Mode toggle alongside play/pause and torch."
                        )

                        featureRow(
                            icon: "airpodspro",
                            color: .green,
                            title: "Interactive Route Switcher",
                            desc: "Tap the audio route icon directly in compact mode to instantly open the native AirPlay audio routing sheet."
                        )

                        featureRow(
                            icon: "arrow.turn.up.right",
                            color: Color(red: 0.18, green: 0.84, blue: 0.38),
                            title: "Apple Maps Navigation HUD",
                            desc: "Turn-by-turn green highway navigation shield with distance readout, street name, speed limit badge, and live ETA."
                        )

                        featureRow(
                            icon: "sportscourt.fill",
                            color: .green,
                            title: "Live Sports Scoreboard",
                            desc: "Real-time match scoring (e.g. RMA 2 - 1 FCB), live game clock, goal scorer ticker, and stadium details directly in the notch."
                        )

                        featureRow(
                            icon: "record.circle.fill",
                            color: .red,
                            title: "Native Voice Memo Recording",
                            desc: "Live blinking recording indicator, animated audio waveform, and elapsed timer counter directly in the floating notch."
                        )

                        featureRow(
                            icon: "speaker.wave.3.fill",
                            color: themeColor,
                            title: "Interactive Draggable Volume Bar",
                            desc: "Slide your finger directly across the Volume HUD in the notch to raise or lower audio volume in real-time."
                        )

                        featureRow(
                            icon: "flask.fill",
                            color: .yellow,
                            title: "Expanded Test Lab (16 Scenarios)",
                            desc: "Simulate Maps turns, Live football goals, Face ID, AirDrop, Personal Hotspot, charger surge, and thermal alerts with a single tap."
                        )

                        featureRow(
                            icon: "music.note.list",
                            color: .cyan,
                            title: "Universal Media & App Badges",
                            desc: "Real-time sync with Spotify, YouTube, Stremio, Safari, and Apple Music with branded source app badges."
                        )

                        featureRow(
                            icon: "airpodspro",
                            color: .green,
                            title: "AirPods Battery & Audio Route Switcher",
                            desc: "Embedded AVRoutePickerView lets you switch audio output and view connected AirPods battery without opening the app."
                        )
                    }
                    .padding(.horizontal, 20)
                }

                Button(action: {
                    HapticService.shared.medium()
                    isPresented = false
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(themeColor)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
    }

    private func featureRow(icon: String, color: Color, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(color)
            }
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

