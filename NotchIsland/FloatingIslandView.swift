import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            // Full OLED Black fill - the entire PiP window is the island
            Color.black
                .ignoresSafeArea()

            // Subtle Apple-style gloss border
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
                .padding(0.5)

            // Centered Island Content
            HStack(spacing: 9) {
                // Leading Accessory
                leadingAccessory

                // Center Title & Subtitle Info
                VStack(alignment: .leading, spacing: 1.5) {
                    Text(state.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(state.subtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(subtitleColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Trailing Accessory
                trailingAccessory
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var subtitleColor: Color {
        if state.mode == .media && nowPlaying.isPlaying {
            return Color(red: 0.18, green: 0.84, blue: 0.38) // Spotify Green
        }
        return Color.gray
    }

    // MARK: - Leading Accessory
    @ViewBuilder
    private var leadingAccessory: some View {
        switch state.mode {
        case .timer:
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.22))
                    .frame(width: 26, height: 26)
                Image(systemName: "timer")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
            }

        case .media:
            if let artwork = nowPlaying.artworkImage {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 26, height: 26)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(red: 0.12, green: 0.84, blue: 0.38)) // Spotify Green
                        .frame(width: 26, height: 26)
                    Image(systemName: "music.note")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.black)
                }
            }

        case .battery:
            ZStack {
                Circle()
                    .fill(batteryColor.opacity(0.22))
                    .frame(width: 26, height: 26)
                Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(batteryColor)
            }
        }
    }

    private var batteryColor: Color {
        if state.isCharging {
            return .green
        } else if state.batteryPercentage <= 10 {
            return .red
        } else if state.batteryPercentage <= 20 {
            return .orange
        } else {
            return .green
        }
    }

    // MARK: - Trailing Accessory
    @ViewBuilder
    private var trailingAccessory: some View {
        switch state.mode {
        case .timer:
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 2.5)
                    .frame(width: 22, height: 22)
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.04, min(1.0, state.progress))))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 22, height: 22)
            }

        case .media:
            EqualizerWaveformView(color: Color(red: 0.18, green: 0.84, blue: 0.38))

        case .battery:
            HStack(spacing: 3) {
                Text("\(state.batteryPercentage)%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(batteryColor)
                Image(systemName: state.isCharging ? "bolt.fill" : "battery.25")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(batteryColor)
            }
        }
    }
}

// MARK: - Animated Equalizer Waveform
struct EqualizerWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2.2) {
            bar(minHeight: 4, maxHeight: 16, delay: 0.0)
            bar(minHeight: 14, maxHeight: 6, delay: 0.12)
            bar(minHeight: 5, maxHeight: 17, delay: 0.06)
            bar(minHeight: 13, maxHeight: 4, delay: 0.18)
        }
        .frame(height: 18)
        .onAppear {
            animating = true
        }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 1.2)
            .fill(color)
            .frame(width: 2.5, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: 0.38)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
    }
}
