import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared
    @ObservedObject var nowPlaying = NowPlayingService.shared
    @ObservedObject var battery = BatteryService.shared
    @ObservedObject var bgEngine = BackgroundEngine.shared

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

                    // Activity Mode Switcher (All 6 features)
                    activitySelector

                    // Mode-Specific Interactive Controls
                    modeInteractiveSection

                    // Accent Theme Picker
                    themeSection

                    // Notch Sizing Profile
                    notchProfileSection

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
                    FloatingIslandView(state: state)
                        .frame(width: state.islandWidth, height: state.islandHeight)
                        .clipShape(RoundedRectangle(cornerRadius: state.isExpanded ? 28 : 24, style: .continuous))
                        .shadow(color: .black.opacity(0.7), radius: 12, x: 0, y: 4)

                    PiPAnchorRepresentable()
                        .frame(width: state.islandWidth, height: state.islandHeight)
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

    // MARK: - Activity Mode Selector
    private var activitySelector: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DYNAMIC ACTIVITIES")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.gray.opacity(0.8))
                .kerning(1.2)
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

    // MARK: - Media Controls
    private var mediaControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "music.note.list")
                    .foregroundColor(state.theme.color)
                Text("Spotify & Media Integration")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text(nowPlaying.isPlaying ? "Playing" : "Standby")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(nowPlaying.isPlaying ? .green : .gray)
            }

            Text("Song: \(state.mediaTitle)")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)

            Text("Artist: \(state.mediaArtist)")
                .font(.system(size: 10.5))
                .foregroundColor(.gray)

            Divider().background(Color.white.opacity(0.1))

            HStack {
                Button(action: {
                    nowPlaying.requestAllPermissions()
                }) {
                    Text("Sync Now Playing & Re-check")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(state.theme.color)
                        .clipShape(Capsule())
                }

                Spacer()

                Button(action: {
                    state.toggleExpanded()
                }) {
                    Text(state.isExpanded ? "Collapse Island" : "Expand Island")
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
                withAnimation {
                    state.isSilentOn.toggle()
                }
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

    // MARK: - Notch Sizing Profiles
    private var notchProfileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTCH PROFILE")
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.gray.opacity(0.8))
                .kerning(1.2)
                .padding(.horizontal, 4)

            HStack(spacing: 8) {
                ForEach(IslandSize.allCases, id: \.self) { sizeOption in
                    Button(action: {
                        state.setSize(sizeOption)
                    }) {
                        Text(sizeOption.rawValue)
                            .font(.system(size: 11.5, weight: .semibold))
                            .foregroundColor(state.size == sizeOption ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(state.size == sizeOption ? Color.white : Color(white: 0.13))
                            )
                    }
                }
            }
        }
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
                Text("Spotify / EeveeSpotify Setup:")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                Text("In Spotify Settings > Devices, turn ON 'Device Broadcast Status' so track titles stream to Dynamic Notch.")
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
        switch mode {
        case .media: return "music.note"
        case .call: return "phone.fill"
        case .timer: return "timer"
        case .stopwatch: return "stopwatch"
        case .battery: return "battery.100.bolt"
        case .silent: return "bell.badge.fill"
        }
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

