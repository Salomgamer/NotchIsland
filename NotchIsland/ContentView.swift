import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.06)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Text("Notch Island")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("2.0")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.18, green: 0.84, blue: 0.38))
                                .clipShape(Capsule())
                        }

                        Text("Live Spotify & Dynamic Notch for iPhone 11")
                            .font(.system(size: 13.5, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 10)

                    // Live Preview with Simulated Notch & Active PiP Anchor
                    VStack(spacing: 8) {
                        Text("LIVE FLOATER PREVIEW")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.gray.opacity(0.8))
                            .kerning(1.2)

                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(Color(white: 0.11))
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
                                        .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)

                                    PiPAnchorRepresentable()
                                        .frame(width: state.islandWidth, height: state.islandHeight)
                                }

                                Spacer()
                            }
                        }
                    }

                    // Prominent Launch Button (Right below preview)
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
                        .shadow(color: (pip.isPiPActive ? Color.red : Color(red: 0.18, green: 0.84, blue: 0.38)).opacity(0.38), radius: 10, x: 0, y: 5)
                    }

                    // How to lock under notch guide
                    HStack(spacing: 12) {
                        Image(systemName: "lock.shield.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.18, green: 0.84, blue: 0.38))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("How to lock under your notch:")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("Tap Launch above, swipe Home, then drag the pill to top-center. It snaps magnetically under the physical notch.")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(white: 0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    // Notch Profile Switcher
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
                                    pip.updateSize(width: state.islandWidth, height: state.islandHeight)
                                }) {
                                    Text(sizeOption.rawValue)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(state.size == sizeOption ? .black : .white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                                .fill(state.size == sizeOption ? Color.white : Color(white: 0.16))
                                        )
                                }
                            }
                        }
                    }

                    // Live Activity Switcher
                    VStack(alignment: .leading, spacing: 8) {
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
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(state.mode == mode ? (mode == .media ? Color(red: 0.18, green: 0.84, blue: 0.38) : Color.orange) : Color(white: 0.16))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 36)
            }
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
