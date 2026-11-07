import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState

    var body: some View {
        HStack(spacing: 6) {
            // Leading Accessory
            leadingAccessory

            Spacer(minLength: 1)

            // Center Content (Title in Standard/Compact modes)
            if state.showCenterText && !state.centerText.isEmpty {
                Text(state.centerText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 1)

            // Trailing Accessory
            trailingAccessory
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .frame(width: state.islandWidth, height: state.islandHeight)
        .background(Color.black)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 0.8)
        )
    }

    // MARK: - Leading Accessory
    @ViewBuilder
    private var leadingAccessory: some View {
        switch state.mode {
        case .timer:
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.22))
                    .frame(width: 18, height: 18)
                Image(systemName: "timer")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.orange)
            }

        case .media:
            ZStack {
                RoundedRectangle(cornerRadius: 4.5, style: .continuous)
                    .fill(Color(red: 0.95, green: 0.22, blue: 0.35))
                    .frame(width: 18, height: 18)
                Image(systemName: "music.note")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(.white)
            }

        case .battery:
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.22))
                    .frame(width: 18, height: 18)
                Image(systemName: "bolt.fill")
                    .font(.system(size: 9.5, weight: .bold))
                    .foregroundColor(.green)
            }
        }
    }

    // MARK: - Trailing Accessory
    @ViewBuilder
    private var trailingAccessory: some View {
        switch state.mode {
        case .timer:
            HStack(spacing: 3) {
                Text(state.timerFormatted)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1.8)
                        .frame(width: 12, height: 12)
                    Circle()
                        .trim(from: 0, to: CGFloat(max(0.04, min(1.0, state.progress))))
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 12, height: 12)
                }
            }

        case .media:
            EqualizerWaveformView(color: Color(red: 0.18, green: 0.84, blue: 0.38))

        case .battery:
            HStack(spacing: 2) {
                Text("\(state.batteryPercentage)%")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                Image(systemName: "battery.100.bolt")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Animated Equalizer Waveform
struct EqualizerWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 1.8) {
            bar(minHeight: 3, maxHeight: 11, delay: 0.0)
            bar(minHeight: 10, maxHeight: 4, delay: 0.12)
            bar(minHeight: 4, maxHeight: 12, delay: 0.06)
            bar(minHeight: 9, maxHeight: 3, delay: 0.18)
        }
        .frame(height: 12)
        .onAppear {
            animating = true
        }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(color)
            .frame(width: 2, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: 0.4)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
    }
}
