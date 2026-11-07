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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(glowColor.opacity(0.40), lineWidth: 1.2)
                    .shadow(color: glowColor.opacity(0.45), radius: 6, x: 0, y: 0)
                    .padding(0.5)
            } else {
                // Subtle Apple-style gloss border
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    .padding(0.5)
            }

            // Dynamic Island Content
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            state.toggleExpanded()
        }
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
            // Leading: Song Album Cover Thumbnail
            songCoverThumbnail

            // Center: Song Name & Source/Artist
            VStack(alignment: .leading, spacing: 0.5) {
                Text(state.mode == .call ? state.callerName : state.mediaTitle)
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(state.mode == .call ? state.callerSubtitle : state.mediaArtist)
                    .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                    .foregroundColor(subtitleColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
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

    // MARK: - Song Cover Thumbnail
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
