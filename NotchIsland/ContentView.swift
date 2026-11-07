import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.06)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 4) {
                    Text("Notch Island")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Precision Dynamic Island for iPhone 11")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)

                // Live Preview with Simulated Notch
                VStack(spacing: 10) {
                    Text("LIVE FLOATER PREVIEW")
                        .font(.system(size: 10.5, weight: .bold))
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

                            // Floating Island Preview
                            FloatingIslandView(state: state)
                                .frame(width: state.islandWidth, height: state.islandHeight)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: .black.opacity(0.6), radius: 8, x: 0, y: 4)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Size Switcher
                VStack(alignment: .leading, spacing: 8) {
                    Text("PILL PROFILE")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                        .kerning(1.2)
                        .padding(.horizontal, 24)

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
                    .padding(.horizontal, 20)
                }

                // Activity Mode Selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("LIVE ACTIVITY")
                        .font(.system(size: 10.5, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                        .kerning(1.2)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach(IslandMode.allCases, id: \.self) { mode in
                            Button(action: {
                                state.setMode(mode)
                                pip.updateSize(width: state.islandWidth, height: state.islandHeight)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: iconForMode(mode))
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(mode.rawValue)
                                        .font(.system(size: 12.5, weight: .medium))
                                }
                                .foregroundColor(state.mode == mode ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(state.mode == mode ? Color.orange : Color(white: 0.16))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Launch / Dismiss Button
                VStack(spacing: 10) {
                    Button(action: {
                        pip.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: pip.isPiPActive ? "stop.fill" : "play.fill")
                                .font(.system(size: 15, weight: .bold))
                            Text(pip.isPiPActive ? "Dismiss Island Overlay" : "Launch Floating Island")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(pip.isPiPActive ? Color.red : Color.white)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)

                    Text("When launched, swipe Home and drag it to the top under your notch.")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 20)

                // Invisible PiP Anchor
                PiPAnchorView()
                    .frame(width: 1, height: 1)
                    .opacity(0.01)
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

struct PiPAnchorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            PiPIslandManager.shared.attach(to: view)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
