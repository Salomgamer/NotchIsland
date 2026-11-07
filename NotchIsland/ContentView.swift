import SwiftUI

struct ContentView: View {
    @ObservedObject var state = IslandState.shared
    @ObservedObject var pip = PiPIslandManager.shared

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.07, blue: 0.08)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                // Header
                VStack(spacing: 6) {
                    Text("Notch Island")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Dynamic Island for iPhone 11")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.top, 20)

                // Simulated Notch & Island Preview
                VStack(spacing: 12) {
                    Text("LIVE PREVIEW")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                        .kerning(1.2)

                    ZStack {
                        // Background card
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(Color(white: 0.12))
                            .frame(height: 120)

                        VStack(spacing: 0) {
                            // Simulated Notch Top
                            Path { path in
                                path.move(to: CGPoint(x: 100, y: 0))
                                path.addLine(to: CGPoint(x: 130, y: 24))
                                path.addLine(to: CGPoint(x: 270, y: 24))
                                path.addLine(to: CGPoint(x: 300, y: 0))
                            }
                            .fill(Color.black)
                            .frame(height: 24)

                            Spacer()

                            // Floating Island UI
                            FloatingIslandView(state: state)

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                }

                // Mode Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text("CHOOSE ACTIVITY")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.8))
                        .kerning(1.2)
                        .padding(.horizontal, 24)

                    HStack(spacing: 12) {
                        ForEach(IslandMode.allCases, id: \.self) { mode in
                            Button(action: {
                                state.setMode(mode)
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: iconForMode(mode))
                                        .font(.system(size: 18, weight: .semibold))
                                    Text(mode.rawValue)
                                        .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundColor(state.mode == mode ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(state.mode == mode ? Color.white : Color(white: 0.16))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()

                // Launch / Stop Button
                VStack(spacing: 12) {
                    Button(action: {
                        pip.toggle()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: pip.isPiPActive ? "stop.fill" : "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text(pip.isPiPActive ? "Dismiss Island Overlay" : "Launch Floating Island")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(pip.isPiPActive ? Color.red : Color.orange)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 24)

                    Text("Tip: When it pops up, drag the pill directly under your notch!")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 24)

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
        PiPIslandManager.shared.attach(to: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
