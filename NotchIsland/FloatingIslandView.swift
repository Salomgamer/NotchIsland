import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            // True OLED Black fill
            Color.black
                .ignoresSafeArea()

            // Dynamic ambient glow border
            if state.mode == .media, let glowColor = nowPlaying.artworkAccentColor {
                RoundedRectangle(cornerRadius: state.isExpanded ? 24 : 18, style: .continuous)
                    .stroke(glowColor.opacity(0.40), lineWidth: 1.2)
                    .shadow(color: glowColor.opacity(0.45), radius: 6, x: 0, y: 0)
                    .padding(0.5)
            } else {
                // Subtle Apple-style gloss border
                RoundedRectangle(cornerRadius: state.isExpanded ? 24 : 18, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    .padding(0.5)
            }

            // Dynamic Island Content
            if state.isExpanded {
                if state.isShowingNotification {
                    notificationExpandedContent
                } else {
                    normalExpandedContent
                }
            } else {
                multipurposeCompactContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            state.toggleExpanded()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isShowingNotification)
    }

    // MARK: - Multipurpose Compact Content (Music + Battery Together)
    private var multipurposeCompactContent: some View {
        HStack(spacing: 6) {
            // Leading: Song Album Cover Thumbnail
            songCoverThumbnail

            // Center: Song Name & Source/Artist
            VStack(alignment: .leading, spacing: 0.5) {
                Text(state.mediaTitle)
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(state.mediaArtist)
                    .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                    .foregroundColor(subtitleColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Trailing: Multipurpose Equalizer + Exact Battery Together
            HStack(spacing: 4) {
                if nowPlaying.isPlaying {
                    EqualizerWaveformView(color: subtitleColor)
                }

                HStack(spacing: 2) {
                    Text("\(state.batteryPercentage)%")
                        .font(.system(size: 9.5, weight: .bold, design: .rounded))
                        .foregroundColor(batteryColor)

                    Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(batteryColor)
                }
            }
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
    }

    // MARK: - Song Cover Thumbnail
    @ViewBuilder
    private var songCoverThumbnail: some View {
        if let artwork = nowPlaying.artworkImage {
            Image(uiImage: artwork)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 22, height: 22)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                )
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(subtitleColor)
                    .frame(width: 22, height: 22)
                Image(systemName: "music.note")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.black)
            }
        }
    }

    // MARK: - Notification Auto-Expanded Content
    private var notificationExpandedContent: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(subtitleColor.opacity(0.25))
                    .frame(width: 28, height: 28)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(subtitleColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(state.activeNotificationTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(state.activeNotificationSubtitle)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Circle()
                .fill(subtitleColor)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Normal Expanded Content
    private var normalExpandedContent: some View {
        VStack(spacing: 6) {
            // Header Row: Large Album Cover, Song Title & Source
            HStack(spacing: 10) {
                if let artwork = nowPlaying.artworkImage {
                    Image(uiImage: artwork)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(subtitleColor)
                            .frame(width: 32, height: 32)
                        Image(systemName: "music.note")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.mediaTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Text(state.mediaArtist)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(subtitleColor)
                            .lineLimit(1)

                        Text("• \(nowPlaying.sourceAppName)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Battery badge in top-right
                HStack(spacing: 2) {
                    Text("\(state.batteryPercentage)%")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(batteryColor)
                    Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(batteryColor)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.10))
                .clipShape(Capsule())
            }

            // Controls Row: Previous, Play/Pause, Next & Progress Bar
            HStack(spacing: 12) {
                Button(action: { nowPlaying.previousTrack() }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Button(action: { nowPlaying.togglePlayPause() }) {
                    Image(systemName: nowPlaying.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(subtitleColor)
                }

                Button(action: { nowPlaying.nextTrack() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }

                // Compact track progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.20))
                            .frame(height: 3)
                        Capsule()
                            .fill(subtitleColor)
                            .frame(width: max(4, geo.size.width * CGFloat(state.mediaProgress)), height: 3)
                    }
                }
                .frame(height: 3)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
    }

    private var subtitleColor: Color {
        return nowPlaying.artworkAccentColor ?? state.theme.color
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
}

// MARK: - Animated Equalizer Waveform
struct EqualizerWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 1.8) {
            bar(minHeight: 3, maxHeight: 11, delay: 0.0)
            bar(minHeight: 9, maxHeight: 4, delay: 0.12)
            bar(minHeight: 4, maxHeight: 12, delay: 0.06)
        }
        .frame(height: 12)
        .onAppear {
            animating = true
        }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 0.8)
            .fill(color)
            .frame(width: 1.8, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: 0.38)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
    }
}
