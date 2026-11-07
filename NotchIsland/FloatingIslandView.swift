import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState

    var body: some View {
        HStack(spacing: 10) {
            // Left Status Icon with Subtle Glow
            ZStack {
                Circle()
                    .fill(state.accentColor.opacity(0.18))
                    .frame(width: 30, height: 30)

                Image(systemName: state.iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(state.accentColor)
            }

            // Center Info
            VStack(alignment: .leading, spacing: 2) {
                Text(state.title)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(state.subtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer(minLength: 4)

            // Right Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 3)
                    .frame(width: 22, height: 22)

                Circle()
                    .trim(from: 0.0, to: CGFloat(max(0.02, min(1.0, state.progress))))
                    .stroke(state.accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 22, height: 22)
                    .animation(.linear(duration: 0.3), value: state.progress)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(width: 216, height: 48)
        .background(Color.black)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }
}
