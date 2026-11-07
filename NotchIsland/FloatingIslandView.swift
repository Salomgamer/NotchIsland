import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            // The entire excess PiP window margin is 100% transparent
            Color.clear

            // The Little Island Pill centered in the middle of the PiP
            ZStack {
                // True OLED Black fill for the pill itself
                Color.black

                // Dynamic ambient glow border
                if state.mode == .media, let glowColor = nowPlaying.artworkAccentColor {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(glowColor.opacity(0.45), lineWidth: 1.2)
                        .shadow(color: glowColor.opacity(0.50), radius: 6, x: 0, y: 0)
                        .padding(0.5)
                } else {
                    // Subtle Apple-style gloss border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                        .padding(0.5)
                }

                // Dynamic Island Internal Content
                if state.isShowingVolumeHUD {
                    volumeHUDContent
                } else if state.isExpanded {
                    if state.isShowingNotification {
                        notificationExpandedContent
                    } else {
                        expandedActivityContent
                    }
                } else {
                    multipurposeCompactContent
                }
            }
            .frame(width: state.islandWidth, height: state.islandHeight)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.65), radius: 8, x: 0, y: 3)
            .contentShape(Rectangle())
            .onTapGesture {
                state.toggleExpanded()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isShowingNotification)
        .animation(.spring(response: 0.30, dampingFraction: 0.75), value: state.isShowingVolumeHUD)
    }

    private var cornerRadius: CGFloat {
        if state.useCustomSize {
            return state.isExpanded ? state.customCornerRadius + 6 : state.customCornerRadius
        }
        return state.isExpanded ? 24 : 18
    }

    // MARK: - Volume HUD Content
    private var volumeHUDContent: some View {
        HStack(spacing: 8) {
            Image(systemName: state.systemVolume == 0 ? "speaker.slash.fill" : "speaker.wave.3.fill")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(height: 4.5)
                    Capsule()
                        .fill(state.theme.color)
                        .frame(width: max(4, geo.size.width * CGFloat(state.systemVolume)), height: 4.5)
                }
            }
            .frame(height: 5)

            Text("\(Int(state.systemVolume * 100))%")
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
    }

    // MARK: - Multipurpose Compact Content (Music + Battery Together)
    private var multipurposeCompactContent: some View {
        HStack(spacing: 6) {
            // Leading: Song Cover Thumbnail with Playing App Badge
            songCoverThumbnail

            // Center: Song Name & Source/Artist
            VStack(alignment: .leading, spacing: 0.5) {
                Text(state.mode == .call ? state.callerName : state.mediaTitle)
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                HStack(spacing: 3) {
                    Text(state.mode == .call ? state.callerSubtitle : state.mediaArtist)
                        .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                        .foregroundColor(subtitleColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Trailing: Multipurpose Equalizer + Exact Battery Together
            HStack(spacing: 4) {
                if state.mode == .call {
                    if state.isCallActive {
                        VoiceWaveformView(color: Color.green)
                    } else {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }
                } else if nowPlaying.isPlaying {
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

    // MARK: - Song Cover Thumbnail with App Icon
    @ViewBuilder
    private var songCoverThumbnail: some View {
        if state.mode == .call {
            ZStack {
                Circle()
                    .fill(state.isCallActive ? Color.green : Color.orange)
                    .frame(width: 22, height: 22)
                Image(systemName: "phone.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
        } else if let artwork = nowPlaying.artworkImage {
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 22, height: 22)
                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                    )

                // Mini Source App Icon Badge
                AppSourceIconView(source: nowPlaying.sourceAppName, size: 8)
                    .offset(x: 2, y: 2)
            }
        } else {
            // Full App Icon Squircle
            AppSourceIconView(source: nowPlaying.sourceAppName, size: 22)
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

    // MARK: - Expanded Activity Content
    @ViewBuilder
    private var expandedActivityContent: some View {
        switch state.mode {
        case .media:
            expandedMediaContent

        case .call:
            expandedCallContent

        case .timer:
            expandedTimerContent

        case .stopwatch:
            expandedStopwatchContent

        case .battery:
            expandedBatteryContent

        case .silent:
            expandedSilentContent
        }
    }

    // MARK: - Expanded Media
    private var expandedMediaContent: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                if let artwork = nowPlaying.artworkImage {
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

                        AppSourceIconView(source: nowPlaying.sourceAppName, size: 10)
                            .offset(x: 2, y: 2)
                    }
                } else {
                    AppSourceIconView(source: nowPlaying.sourceAppName, size: 32)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.mediaTitle)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 5) {
                        Text(state.mediaArtist)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(subtitleColor)
                            .lineLimit(1)

                        HStack(spacing: 2) {
                            Circle()
                                .fill(subtitleColor)
                                .frame(width: 3, height: 3)
                            Text(nowPlaying.sourceAppName)
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

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

    // MARK: - Expanded Call
    private var expandedCallContent: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(state.isCallActive ? Color.green : Color.orange)
                        .frame(width: 30, height: 30)
                    Image(systemName: "phone.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.callerName)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(state.callerSubtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(state.isCallActive ? .green : .orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if state.isCallActive {
                    VoiceWaveformView(color: Color.green)
                }
            }

            HStack(spacing: 12) {
                if !state.isCallActive {
                    Button(action: { state.declineCall() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.down.fill")
                            Text("Decline")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .clipShape(Capsule())
                    }

                    Button(action: { state.answerCall() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "phone.fill")
                            Text("Accept")
                        }
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                } else {
                    Button(action: { state.toggleCallMute() }) {
                        Image(systemName: state.isCallMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(state.isCallMuted ? .red : .white)
                            .padding(6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Button(action: { state.toggleSpeaker() }) {
                        Image(systemName: state.isSpeakerOn ? "speaker.wave.3.fill" : "speaker.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(state.isSpeakerOn ? .green : .white)
                            .padding(6)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Button(action: { state.declineCall() }) {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
    }

    // MARK: - Expanded Timer
    private var expandedTimerContent: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 3)
                    .frame(width: 32, height: 32)
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.04, min(1.0, (state.totalSeconds - state.remainingSeconds) / max(1.0, state.totalSeconds)))))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 32, height: 32)
                Image(systemName: "timer")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.orange)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Focus Session")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(state.timerFormatted)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Button(action: { state.setTimerPreset(minutes: 5) }) {
                    Text("5m")
                        .font(.system(size: 9.5, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }
                Button(action: { state.setTimerPreset(minutes: 25) }) {
                    Text("25m")
                        .font(.system(size: 9.5, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .foregroundColor(.white)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Stopwatch
    private var expandedStopwatchContent: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(state.theme.color.opacity(0.22))
                    .frame(width: 30, height: 30)
                Image(systemName: "stopwatch.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(state.theme.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Stopwatch")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(state.stopwatchFormatted)
                    .font(.system(size: 13.5, weight: .bold, design: .monospaced))
                    .foregroundColor(state.theme.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Button(action: {
                    if state.isStopwatchRunning {
                        state.isStopwatchRunning = false
                    } else {
                        state.startStopwatch()
                    }
                }) {
                    Text(state.isStopwatchRunning ? "Pause" : "Start")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(state.theme.color)
                        .clipShape(Capsule())
                }

                Button(action: { state.recordLap() }) {
                    Text("Lap")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.18))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Battery
    private var expandedBatteryContent: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(batteryColor.opacity(0.22))
                    .frame(width: 30, height: 30)
                Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(batteryColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("iPhone 11 Battery")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(state.isCharging ? "Fast Charging • \(state.batteryPercentage)%" : "\(state.batteryPercentage)% Remaining (Exact 1%)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(batteryColor)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(state.batteryPercentage)%")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(batteryColor)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Silent
    private var expandedSilentContent: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill((state.isSilentOn ? Color.red : Color.green).opacity(0.22))
                    .frame(width: 30, height: 30)
                Image(systemName: state.isSilentOn ? "bell.slash.fill" : "bell.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(state.isSilentOn ? Color.red : Color.green)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(state.isSilentOn ? "Silent Mode" : "Ring Mode")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(state.isSilentOn ? "Mute Active • Haptics Only" : "Sound Enabled • Full Volume")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(state.isSilentOn ? "MUTED" : "RING")
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundColor(state.isSilentOn ? Color.red : Color.green)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background((state.isSilentOn ? Color.red : Color.green).opacity(0.2))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
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

// MARK: - App Source Icon View (YouTube, Spotify, Safari, Stremio, etc.)
struct AppSourceIconView: View {
    let source: String
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: max(2, size * 0.28), style: .continuous)
                .fill(appColor)
                .frame(width: size, height: size)

            Image(systemName: appIcon)
                .font(.system(size: size * 0.52, weight: .bold))
                .foregroundColor(.white)
        }
    }

    private var appColor: Color {
        let lower = source.lowercased()
        if lower.contains("youtube") { return Color(red: 1.0, green: 0.0, blue: 0.0) } // YouTube Red
        if lower.contains("spotify") { return Color(red: 0.12, green: 0.84, blue: 0.38) } // Spotify Green
        if lower.contains("safari") { return Color(red: 0.0, green: 0.48, blue: 1.0) } // Safari Blue
        if lower.contains("stremio") { return Color(red: 0.45, green: 0.25, blue: 0.75) } // Stremio Purple
        if lower.contains("music") { return Color(red: 0.98, green: 0.22, blue: 0.38) } // Apple Music Pink
        if lower.contains("soundcloud") { return Color(red: 1.0, green: 0.45, blue: 0.0) } // SoundCloud Orange
        if lower.contains("netflix") { return Color(red: 0.89, green: 0.04, blue: 0.08) } // Netflix Red
        if lower.contains("twitch") { return Color(red: 0.57, green: 0.27, blue: 1.0) } // Twitch Purple
        return Color(red: 0.18, green: 0.84, blue: 0.38)
    }

    private var appIcon: String {
        let lower = source.lowercased()
        if lower.contains("youtube") { return "play.rectangle.fill" }
        if lower.contains("spotify") { return "waveform" }
        if lower.contains("safari") { return "safari.fill" }
        if lower.contains("stremio") { return "film.fill" }
        if lower.contains("music") { return "music.note" }
        if lower.contains("soundcloud") { return "cloud.fill" }
        if lower.contains("netflix") { return "tv.fill" }
        if lower.contains("twitch") { return "video.fill" }
        return "music.note"
    }
}

// MARK: - Animated Voice Waveform (Call HUD)
struct VoiceWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2.0) {
            bar(minHeight: 3, maxHeight: 12, delay: 0.0)
            bar(minHeight: 10, maxHeight: 4, delay: 0.10)
            bar(minHeight: 4, maxHeight: 14, delay: 0.05)
            bar(minHeight: 9, maxHeight: 3, delay: 0.15)
        }
        .frame(height: 14)
        .onAppear { animating = true }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 1.0)
            .fill(color)
            .frame(width: 2.0, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: 0.35)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
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
        .onAppear { animating = true }
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
