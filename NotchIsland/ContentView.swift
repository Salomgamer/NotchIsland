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
                    // Top App Bar
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Notch Island")
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
                                .fill(Color(red: 0.18, green: 0.84, blue: 0.38))
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

                    // Full-width Live Floater Preview with Simulated Notch & Active PiP Anchor
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 0.10))
                            .frame(height: 125)

                        VStack(spacing: 0) {
                            // iPhone 11 Physical Notch Shape
                            Path { path in
                                path.move(to: CGPoint(x: 100, y: 0))
                                path.addLine(to: CGPoint(x: 125, y: 24))
                                path.addLine(to: CGPoint(x: 275, y: 24))
                                path.addLine(to: CGPoint(x: 300, y: 0))
                            }
                            .fill(Color.black)
                            .frame(height: 24)

                            Spacer()

                            // Active Anchor & Island Display
                            ZStack {
                                FloatingIslandView(state: state)
                                    .frame(width: state.islandWidth, height: state.islandHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .shadow(color: .black.opacity(0.65), radius: 10, x: 0, y: 4)

                                PiPAnchorRepresentable()
                                    .frame(width: state.islandWidth, height: state.islandHeight)
                            }

                            Spacer()
                        }
                    }

                    // Prominent Full-Width Launch Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        pip.toggle()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: pip.isPiPActive ? "stop.fill" : "play.fill")
                                .font(.system(size: 17, weight: .bold))
                            Text(pip.isPiPActive ? "Dismiss Floating Island" : "Launch Floating Island 2.0")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(pip.isPiPActive ? Color.red : Color(red: 0.18, green: 0.84, blue: 0.38))
                        .clipShape(Capsule())
                        .shadow(color: (pip.isPiPActive ? Color.red : Color(red: 0.18, green: 0.84, blue: 0.38)).opacity(0.40), radius: 10, x: 0, y: 5)
                    }

                    // Permissions & Accuracy Sync Box
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 0.18, green: 0.84, blue: 0.38))

                            Text("SYSTEM PERMISSIONS & ACCURACY")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)

                            Spacer()

                            if nowPlaying.hasMediaPermission {
                                Text("Active ✓")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 0.18, green: 0.84, blue: 0.38))
                            }
                        }

                        Button(action: {
                            nowPlaying.requestAllPermissions()
                        }) {
                            HStack {
                                Image(systemName: nowPlaying.hasMediaPermission ? "checkmark.circle.fill" : "lock.open.fill")
                                    .foregroundColor(nowPlaying.hasMediaPermission ? .green : .white)
                                Text(nowPlaying.hasMediaPermission ? "Permissions Granted & Synchronized" : "Grant Music & System Permissions")
                                    .font(.system(size: 12.5, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(Color(white: 0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                        // Spotify Device Broadcast Tip
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.green)
                                .padding(.top, 1)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Spotify / EeveeSpotify Setup:")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                Text("In Spotify Settings > Devices, turn ON 'Device Broadcast Status' so Spotify continuously shares track titles with Notch Island.")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.09))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // Lock Under Notch Banner
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.18, green: 0.84, blue: 0.38))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Lock Under Notch (iPhone 11)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("Launch floater, swipe Home, then drag to top-center. It snaps magnetically under the physical notch.")
                                .font(.system(size: 10.5))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.09))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    // Notch Profile Switcher
                    VStack(alignment: .leading, spacing: 6) {
                        Text("NOTCH PROFILE")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .kerning(1.2)
                            .padding(.horizontal, 4)

                        HStack(spacing: 8) {
                            ForEach(IslandSize.allCases, id: \.self) { sizeOption in
                                Button(action: {
                                    state.setSize(sizeOption)
                                    pip.updateSize(width: state.islandWidth, height: state.islandHeight)
                                }) {
                                    Text(sizeOption.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(state.size == sizeOption ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(state.size == sizeOption ? Color.white : Color(white: 0.14))
                                        )
                                }
                            }
                        }
                    }

                    // Live Activity Switcher
                    VStack(alignment: .leading, spacing: 6) {
                        Text("LIVE ACTIVITY")
                            .font(.system(size: 10.5, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .kerning(1.2)
                            .padding(.horizontal, 4)

                        HStack(spacing: 10) {
                            ForEach(IslandMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    state.setMode(mode)
                                    pip.updateSize(width: state.islandWidth, height: state.islandHeight)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: iconForMode(mode))
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(mode == .media ? "Spotify" : mode.rawValue)
                                            .font(.system(size: 12, weight: .medium))
                                    }
                                    .foregroundColor(state.mode == mode ? .black : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 11)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(state.mode == mode ? (mode == .media ? Color(red: 0.18, green: 0.84, blue: 0.38) : Color.orange) : Color(white: 0.14))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 36)
            }
        }
        .onAppear {
            nowPlaying.checkPermissions()
        }
    }

    private func iconForMode(_ mode: IslandMode) -> String {
        switch mode {
        case .timer: return "timer"
        case .media: return "music.note"
        case .battery: return "battery.100.bolt"
        }
    }
}

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
