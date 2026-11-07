import SwiftUI
import AVKit

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            // The entire excess PiP window margin is 100% transparent
            Color.clear

            // The Little Island Pill centered in the middle of the PiP
            ZStack {
                // Configurable Pill Background (OLED, Frosted Glass, Artwork Adaptive, etc.)
                pillBackground

                // Dynamic ambient glow border
                if state.mode == .media, let glowColor = nowPlaying.artworkAccentColor {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(glowColor.opacity(0.50), lineWidth: 1.2)
                        .shadow(color: glowColor.opacity(0.55), radius: 6, x: 0, y: 0)
                        .padding(0.5)
                } else if state.isCharging {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.green.opacity(0.55), lineWidth: 1.2)
                        .shadow(color: Color.green.opacity(0.50), radius: 6, x: 0, y: 0)
                        .padding(0.5)
                } else if BatteryService.shared.isLowPowerMode {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.yellow.opacity(0.50), lineWidth: 1.0)
                        .shadow(color: Color.yellow.opacity(0.40), radius: 5, x: 0, y: 0)
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
            .onTapGesture(count: 2) {
                state.handleDoubleTap()
            }
            .onTapGesture(count: 1) {
                state.toggleExpanded()
            }
            .onLongPressGesture(minimumDuration: 0.6) {
                state.cycleNextMode()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isExpanded)
        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: state.isShowingNotification)
        .animation(.spring(response: 0.30, dampingFraction: 0.75), value: state.isShowingVolumeHUD)
    }

    // MARK: - Pill Background Fill
    @ViewBuilder
    private var pillBackground: some View {
        switch state.backgroundStyle {
        case .oledBlack:
            Color.black
                .opacity(state.backgroundOpacity)

        case .frostedGlass:
            ZStack {
                Color(white: 0.12).opacity(state.backgroundOpacity * 0.88)
                LinearGradient(
                    colors: [Color.white.opacity(0.18), Color.white.opacity(0.04), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }

        case .artworkAdaptive:
            if let accent = nowPlaying.artworkAccentColor {
                ZStack {
                    Color.black.opacity(state.backgroundOpacity)
                    LinearGradient(
                        colors: [accent.opacity(0.48 * state.backgroundOpacity), Color.black.opacity(0.85 * state.backgroundOpacity)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                ZStack {
                    Color.black.opacity(state.backgroundOpacity)
                    LinearGradient(
                        colors: [state.theme.color.opacity(0.35 * state.backgroundOpacity), Color.black.opacity(0.85 * state.backgroundOpacity)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }

        case .midnightNavy:
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.09, blue: 0.22).opacity(state.backgroundOpacity), Color(red: 0.01, green: 0.02, blue: 0.08).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .darkObsidian:
            LinearGradient(
                colors: [Color(white: 0.18).opacity(state.backgroundOpacity), Color(white: 0.06).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .deepCrimson:
            LinearGradient(
                colors: [Color(red: 0.28, green: 0.05, blue: 0.12).opacity(state.backgroundOpacity), Color(red: 0.08, green: 0.01, blue: 0.03).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .cyberNeon:
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.22, blue: 0.26).opacity(state.backgroundOpacity), Color(red: 0.01, green: 0.06, blue: 0.09).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .auroraBorealis:
            LinearGradient(
                colors: [Color(red: 0.02, green: 0.28, blue: 0.22).opacity(state.backgroundOpacity), Color(red: 0.01, green: 0.08, blue: 0.14).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .sunsetHorizon:
            LinearGradient(
                colors: [Color(red: 0.32, green: 0.08, blue: 0.24).opacity(state.backgroundOpacity), Color(red: 0.12, green: 0.04, blue: 0.16).opacity(state.backgroundOpacity)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
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
    @ViewBuilder
    private var multipurposeCompactContent: some View {
        if state.mode == .blank {
            Color.clear
        } else {
            HStack(spacing: 6) {
                // Leading: Song Cover Thumbnail with Playing App Badge
                songCoverThumbnail

                // Center: Song Name & Source/Artist
                VStack(alignment: .leading, spacing: 0.5) {
                    MarqueeText(
                        text: state.mode == .call ? state.callerName : state.mediaTitle,
                        font: .system(size: 10.5, weight: .bold, design: .rounded),
                        color: .white
                    )
                    .frame(height: 13)

                    HStack(spacing: 3) {
                        Text(state.mode == .call ? state.callerSubtitle : state.mediaArtist)
                            .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                            .foregroundColor(subtitleColor)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Trailing: Multipurpose Dual-Activity / Equalizer + Route + Exact Battery Together
                HStack(spacing: 3.5) {
                    if state.mode == .call {
                        if state.isCallActive {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 4.5, height: 4.5)
                            VoiceWaveformView(color: Color.green)
                        } else {
                            Image(systemName: "phone.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.green)
                        }
                    } else {
                        if state.isDualActivityActive {
                            HStack(spacing: 2) {
                                Image(systemName: "timer")
                                    .font(.system(size: 7.5, weight: .bold))
                                    .foregroundColor(.orange)
                                Text(state.timerFormatted)
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(.orange)
                            }
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(Color.orange.opacity(0.22))
                            .clipShape(Capsule())
                        } else if nowPlaying.currentRouteType.isExternalOrHeadphones {
                            Image(systemName: nowPlaying.currentRouteType.iconName)
                                .font(.system(size: 8.5, weight: .bold))
                                .foregroundColor(subtitleColor)
                        }

                        if nowPlaying.isPlaying {
                            audioVisualizer(color: subtitleColor)
                        }
                    }

                    PillBatteryView(
                        percentage: state.batteryPercentage,
                        isCharging: state.isCharging,
                        isLowPower: BatteryService.shared.isLowPowerMode,
                        color: batteryColor
                    )
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
        }
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
        let notifColor = state.activeNotificationColor ?? subtitleColor
        return HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(notifColor.opacity(0.25))
                    .frame(width: 28, height: 28)
                Image(systemName: state.activeNotificationIcon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(notifColor)
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
                .fill(notifColor)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Activity Content
    @ViewBuilder
    private var expandedActivityContent: some View {
        switch state.mode {
        case .blank:
            expandedBlankContent

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

    // MARK: - Expanded Blank / Stealth Status
    private var expandedBlankContent: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: "applelogo")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Dynamic Notch")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Text("\(state.batteryPercentage)%")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(batteryColor)

                    Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(batteryColor)

                    Text("• \(nowPlaying.currentRouteName)")
                        .font(.system(size: 9.5, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 6) {
                Button(action: {
                    TorchService.shared.toggleTorch()
                }) {
                    Image(systemName: TorchService.shared.isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(TorchService.shared.isTorchOn ? .black : .white)
                        .padding(7)
                        .background(TorchService.shared.isTorchOn ? Color.yellow : Color.white.opacity(0.15))
                        .clipShape(Circle())
                }

                Button(action: {
                    state.setMode(.media)
                }) {
                    Image(systemName: "music.note")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(7)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Media
    private var expandedMediaContent: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Button(action: {
                    openPlayingApp()
                }) {
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
                }
                .buttonStyle(PlainButtonStyle())

                VStack(alignment: .leading, spacing: 2) {
                    MarqueeText(
                        text: state.mediaTitle,
                        font: .system(size: 12, weight: .bold, design: .rounded),
                        color: .white
                    )
                    .frame(height: 15)

                    HStack(spacing: 5) {
                        Text(state.mediaArtist)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(subtitleColor)
                            .lineLimit(1)

                        ZStack {
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(subtitleColor)
                                    .frame(width: 3, height: 3)
                                Image(systemName: nowPlaying.currentRouteType.iconName)
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(subtitleColor)
                                Text(nowPlaying.currentRouteName)
                                    .font(.system(size: 8.5, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineLimit(1)
                            }

                            // Invisible touch target that summons native iOS AirPlay route sheet
                            AirPlayRoutePickerRepresentable()
                                .frame(width: 70, height: 16)
                                .opacity(0.015)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                PillBatteryView(
                    percentage: state.batteryPercentage,
                    isCharging: state.isCharging,
                    isLowPower: BatteryService.shared.isLowPowerMode,
                    color: batteryColor
                )
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

                VStack(spacing: 2) {
                    GeometryReader { geo in
                        let progressWidth = max(4, geo.size.width * CGFloat(nowPlaying.trackProgress))
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.20))
                                .frame(height: 4)
                            Capsule()
                                .fill(subtitleColor)
                                .frame(width: progressWidth, height: 4)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 7, height: 7)
                                .shadow(color: .black.opacity(0.5), radius: 2)
                                .offset(x: max(0, progressWidth - 3.5))
                        }
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { val in
                                    let pct = max(0.0, min(1.0, Double(val.location.x / geo.size.width)))
                                    nowPlaying.seek(toProgress: pct)
                                }
                        )
                    }
                    .frame(height: 7)

                    HStack {
                        Text(nowPlaying.elapsedFormatted)
                            .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                        Spacer()
                        Text(nowPlaying.remainingFormatted)
                            .font(.system(size: 7.5, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
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
                    MarqueeText(
                        text: state.callerName,
                        font: .system(size: 12, weight: .bold, design: .rounded),
                        color: .white
                    )
                    .frame(height: 15)
                    Text(state.callerSubtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(state.isCallActive ? .green : .orange)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if state.isCallActive {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 5, height: 5)
                        VoiceWaveformView(color: Color.green)
                    }
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
        HStack(spacing: 10) {
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
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(state.timerFormatted)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.orange)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 5) {
                Button(action: { state.toggleTimer() }) {
                    Image(systemName: state.isTimerRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.black)
                        .padding(6)
                        .background(Color.orange)
                        .clipShape(Circle())
                }

                Button(action: { state.adjustTimer(by: -60) }) {
                    Text("-1m")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                Button(action: { state.adjustTimer(by: 60) }) {
                    Text("+1m")
                        .font(.system(size: 8.5, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.15))
                        .clipShape(Capsule())
                }

                if !state.isTimerRunning && state.remainingSeconds < state.totalSeconds {
                    Button(action: { state.resetTimer() }) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 8.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Circle())
                    }
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

            VStack(alignment: .leading, spacing: 1) {
                HStack(spacing: 4) {
                    Text("Stopwatch")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    if let firstLap = state.stopwatchLaps.first {
                        Text("(\(firstLap))")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }
                Text(state.stopwatchFormatted)
                    .font(.system(size: 13.5, weight: .bold, design: .monospaced))
                    .foregroundColor(state.theme.color)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 5) {
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

                if state.isStopwatchRunning {
                    Button(action: { state.recordLap() }) {
                        Text("Lap")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.18))
                            .clipShape(Capsule())
                    }
                } else if state.stopwatchSeconds > 0 {
                    Button(action: { state.resetStopwatch() }) {
                        Text("Reset")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.4))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    // MARK: - Expanded Battery
    private var expandedBatteryContent: some View {
        let bs = BatteryService.shared
        return VStack(spacing: 5) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(batteryColor.opacity(0.22))
                        .frame(width: 30, height: 30)
                    Image(systemName: state.isCharging ? "bolt.fill" : (bs.isLowPowerMode ? "battery.100.bolt" : "battery.100"))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(batteryColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("iPhone 11 Battery")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    HStack(spacing: 4) {
                        Text(state.isCharging ? "Fast Charging" : (bs.isLowPowerMode ? "Low Power Saver" : "Healthy Discharge"))
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(batteryColor)

                        if let watts = bs.chargingWatts {
                            Text("• \(watts)W")
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(.green)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 5) {
                    Button(action: {
                        HapticService.shared.selection()
                        BatteryService.shared.updateBattery()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(5)
                            .background(Color.white.opacity(0.14))
                            .clipShape(Circle())
                    }

                    Text("\(state.batteryPercentage)%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(batteryColor)
                }
            }

            // Real-Time Hardware Readouts Row (Voltage, Amperage, Temp, Cycles)
            HStack(spacing: 8) {
                if let v = bs.voltageVolts {
                    HStack(spacing: 2) {
                        Image(systemName: "bolt.badge.a")
                            .font(.system(size: 7.5))
                        Text(String(format: "%.2fV", v))
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                if let ma = bs.amperageMilliAmps {
                    HStack(spacing: 2) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 7.5))
                        Text("\(ma > 0 ? "+" : "")\(ma)mA")
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(ma > 0 ? .green : .white.opacity(0.8))
                }

                if let temp = bs.batteryTempCelsius {
                    HStack(spacing: 2) {
                        Image(systemName: "thermometer")
                            .font(.system(size: 7.5))
                        Text(String(format: "%.1f°C", temp))
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                if let cycles = bs.cycleCount {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 7.5))
                        Text("\(cycles) cyc")
                            .font(.system(size: 8.5, weight: .semibold, design: .monospaced))
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 6)
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

            Button(action: {
                state.toggleSilentMode()
            }) {
                Text(state.isSilentOn ? "MUTED" : "RING")
                    .font(.system(size: 9.5, weight: .bold, design: .rounded))
                    .foregroundColor(state.isSilentOn ? Color.red : Color.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((state.isSilentOn ? Color.red : Color.green).opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
    }

    private var subtitleColor: Color {
        return nowPlaying.artworkAccentColor ?? state.theme.color
    }

    private var batteryColor: Color {
        if BatteryService.shared.isLowPowerMode {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // Apple Low Power Mode Yellow
        } else if state.isCharging {
            return .green
        } else if state.batteryPercentage <= 10 {
            return .red
        } else if state.batteryPercentage <= 20 {
            return .orange
        } else {
            return .green
        }
    }

    @ViewBuilder
    private func audioVisualizer(color: Color) -> some View {
        switch state.visualizerStyle {
        case .equalizer:
            EqualizerWaveformView(color: color)
        case .pulseWave:
            VoiceWaveformView(color: color)
        case .breathingDot:
            BreathingDotView(color: color)
        }
    }

    private func openPlayingApp() {
        let app = nowPlaying.sourceAppName.lowercased()
        var urlString: String? = nil
        if app.contains("spotify") {
            urlString = "spotify://"
        } else if app.contains("youtube music") {
            urlString = "youtubemusic://"
        } else if app.contains("youtube") {
            urlString = "youtube://"
        } else if app.contains("music") {
            urlString = "music://"
        } else if app.contains("stremio") {
            urlString = "stremio://"
        } else if app.contains("soundcloud") {
            urlString = "soundcloud://"
        } else if app.contains("safari") {
            urlString = "http://"
        }
        if let str = urlString, let url = URL(string: str), UIApplication.shared.canOpenURL(url) {
            HapticService.shared.medium()
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        if lower.contains("youtube music") { return Color(red: 1.0, green: 0.0, blue: 0.15) }
        if lower.contains("youtube") { return Color(red: 1.0, green: 0.0, blue: 0.0) } // YouTube Red
        if lower.contains("spotify") { return Color(red: 0.12, green: 0.84, blue: 0.38) } // Spotify Green
        if lower.contains("safari") { return Color(red: 0.0, green: 0.48, blue: 1.0) } // Safari Blue
        if lower.contains("stremio") { return Color(red: 0.45, green: 0.25, blue: 0.75) } // Stremio Purple
        if lower.contains("music") { return Color(red: 0.98, green: 0.22, blue: 0.38) } // Apple Music Pink
        if lower.contains("soundcloud") { return Color(red: 1.0, green: 0.45, blue: 0.0) } // SoundCloud Orange
        if lower.contains("netflix") { return Color(red: 0.89, green: 0.04, blue: 0.08) } // Netflix Red
        if lower.contains("twitch") { return Color(red: 0.57, green: 0.27, blue: 1.0) } // Twitch Purple
        if lower.contains("deezer") { return Color(red: 0.65, green: 0.15, blue: 0.95) }
        if lower.contains("audible") { return Color(red: 0.98, green: 0.55, blue: 0.0) }
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
        if lower.contains("audible") { return "book.fill" }
        return "music.note"
    }
}

// MARK: - Animated Voice Waveform (Call HUD)
struct VoiceWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 1.8) {
            bar(minHeight: 2.5, maxHeight: 8.0, delay: 0.0)
            bar(minHeight: 5.0, maxHeight: 12.0, delay: 0.10)
            bar(minHeight: 8.0, maxHeight: 15.0, delay: 0.05)
            bar(minHeight: 5.0, maxHeight: 12.0, delay: 0.15)
            bar(minHeight: 2.5, maxHeight: 8.0, delay: 0.20)
        }
        .frame(height: 15)
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
        HStack(spacing: 1.6) {
            bar(minHeight: 3, maxHeight: 11, duration: 0.38, delay: 0.0)
            bar(minHeight: 10, maxHeight: 4, duration: 0.28, delay: 0.12)
            bar(minHeight: 4, maxHeight: 12, duration: 0.42, delay: 0.06)
            bar(minHeight: 8, maxHeight: 3, duration: 0.32, delay: 0.18)
        }
        .frame(height: 12)
        .onAppear { animating = true }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, duration: Double, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 0.8)
            .fill(color)
            .frame(width: 1.6, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
    }
}

// MARK: - Marquee Auto-Scrolling Text View
struct MarqueeText: View {
    let text: String
    let font: Font
    let color: Color
    var speed: Double = 30.0

    @State private var textWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let containerWidth = geo.size.width
            let shouldScroll = textWidth > containerWidth && containerWidth > 0
            let overflow = max(0, textWidth - containerWidth + 6)

            ZStack(alignment: .leading) {
                // Background invisible text for measuring natural width
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear.preference(
                                key: TextWidthPreferenceKey.self,
                                value: textGeo.size.width
                            )
                        }
                    )
                    .hidden()

                // Foreground displayed text
                if shouldScroll {
                    Text(text)
                        .font(font)
                        .foregroundColor(color)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .offset(x: offset)
                        .onAppear {
                            triggerScrollAnimation(overflow: overflow)
                        }
                        .onChange(of: text) { _ in
                            offset = 0
                            triggerScrollAnimation(overflow: overflow)
                        }
                } else {
                    Text(text)
                        .font(font)
                        .foregroundColor(color)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: containerWidth, alignment: .leading)
            .clipped()
            .onPreferenceChange(TextWidthPreferenceKey.self) { newWidth in
                textWidth = newWidth
                if newWidth > containerWidth && containerWidth > 0 {
                    triggerScrollAnimation(overflow: newWidth - containerWidth + 6)
                } else {
                    offset = 0
                }
            }
        }
    }

    private func triggerScrollAnimation(overflow: CGFloat) {
        guard overflow > 0 else {
            offset = 0
            return
        }
        let duration = Double(overflow) / speed + 1.2
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(
                Animation.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(0.8)
            ) {
                offset = -overflow
            }
        }
    }
}

private struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Animated Breathing Dot Visualizer
struct BreathingDotView: View {
    let color: Color
    @State private var scale: CGFloat = 0.82
    @State private var opacity: Double = 0.60

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 5.5, height: 5.5)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 0.60)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.25
                    opacity = 1.0
                }
            }
    }
}

// MARK: - Pulsing Battery Indicator Pill
struct PillBatteryView: View {
    let percentage: Int
    let isCharging: Bool
    let isLowPower: Bool
    let color: Color

    @State private var pulse: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            Text("\(percentage)%")
                .font(.system(size: 9.5, weight: .bold, design: .rounded))
                .foregroundColor(color)

            Image(systemName: isCharging ? "bolt.fill" : (isLowPower ? "battery.100.bolt" : "battery.100"))
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(color)
                .opacity(isCharging ? (pulse ? 1.0 : 0.6) : (percentage <= 10 ? (pulse ? 1.0 : 0.4) : 1.0))
                .scaleEffect(isCharging ? (pulse ? 1.08 : 0.95) : 1.0)
                .animation(
                    isCharging || percentage <= 10
                        ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        : .default,
                    value: pulse
                )
                .onAppear {
                    pulse = true
                }
        }
    }
}

// MARK: - Native iOS AirPlay & Audio Route Picker
struct AirPlayRoutePickerRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let picker = AVRoutePickerView()
        picker.tintColor = .white
        picker.activeTintColor = UIColor(red: 0.18, green: 0.84, blue: 0.38, alpha: 1.0)
        picker.backgroundColor = .clear
        picker.prioritizesVideoDevices = false
        return picker
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
