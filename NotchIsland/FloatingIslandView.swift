import SwiftUI

struct FloatingIslandView: View {
    @ObservedObject var state: IslandState
    @ObservedObject var nowPlaying = NowPlayingService.shared

    var body: some View {
        ZStack {
            // True OLED Black fill - the entire PiP frame is the island capsule
            Color.black
                .ignoresSafeArea()

            // Subtle Apple-style gloss border
            RoundedRectangle(cornerRadius: state.isExpanded ? 28 : 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                .padding(0.5)

            // Dynamic Island Capsule Content
            if state.isExpanded {
                expandedContent
            } else {
                compactContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            state.toggleExpanded()
        }
    }

    // MARK: - Compact Island Content
    private var compactContent: some View {
        HStack(spacing: 8) {
            leadingAccessory

            // Title & Subtitle Stack
            VStack(alignment: .leading, spacing: 1) {
                Text(modeTitle)
                    .font(.system(size: 11.5, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(modeSubtitle)
                    .font(.system(size: 9.5, weight: .semibold, design: .rounded))
                    .foregroundColor(subtitleColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            trailingAccessory
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 5)
    }

    // MARK: - Expanded Island Content
    private var expandedContent: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                leadingAccessory

                VStack(alignment: .leading, spacing: 2) {
                    Text(modeTitle)
                        .font(.system(size: 12.5, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(modeSubtitle)
                        .font(.system(size: 10.5, weight: .medium, design: .rounded))
                        .foregroundColor(subtitleColor)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                trailingAccessory
            }

            // Expanded Secondary Control Row
            HStack(spacing: 12) {
                switch state.mode {
                case .media:
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.16))
                                .frame(height: 3.5)
                            Capsule()
                                .fill(state.theme.color)
                                .frame(width: geo.size.width * CGFloat(state.mediaProgress), height: 3.5)
                        }
                    }
                    .frame(height: 4)

                case .call:
                    if !state.isCallActive {
                        HStack(spacing: 8) {
                            Button(action: { state.declineCall() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.down.fill")
                                    Text("Decline")
                                }
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.red)
                                .clipShape(Capsule())
                            }

                            Button(action: { state.answerCall() }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "phone.fill")
                                    Text("Accept")
                                }
                                .font(.system(size: 9.5, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green)
                                .clipShape(Capsule())
                            }
                        }
                    } else {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 6, height: 6)
                            Text("Mic Active • High Definition")
                                .font(.system(size: 9.5, weight: .medium))
                                .foregroundColor(.gray)
                        }
                    }

                case .timer:
                    HStack(spacing: 6) {
                        Button(action: { state.setTimerPreset(minutes: 5) }) {
                            Text("5m")
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2.5)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Button(action: { state.setTimerPreset(minutes: 15) }) {
                            Text("15m")
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2.5)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Button(action: { state.setTimerPreset(minutes: 25) }) {
                            Text("25m")
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2.5)
                                .background(Color.white.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    .foregroundColor(.white)

                case .stopwatch:
                    HStack(spacing: 8) {
                        Button(action: { state.startStopwatch() }) {
                            Text(state.isStopwatchRunning ? "Pause" : "Start")
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2.5)
                                .background(state.theme.color)
                                .foregroundColor(.black)
                                .clipShape(Capsule())
                        }
                        Button(action: { state.resetStopwatch() }) {
                            Text("Reset")
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2.5)
                                .background(Color.white.opacity(0.15))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                    }

                case .battery:
                    HStack(spacing: 6) {
                        Circle()
                            .fill(batteryColor)
                            .frame(width: 5, height: 5)
                        Text(state.isCharging ? "Kernel IOKit: Fast Charge Connected" : "Kernel IOKit: Exact 1% HW Monitor")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(.gray)
                    }

                case .silent:
                    HStack(spacing: 6) {
                        Circle()
                            .fill(state.isSilentOn ? Color.red : Color.green)
                            .frame(width: 5, height: 5)
                        Text(state.isSilentOn ? "Ringer Off • Haptics Only" : "Ringer Active • Full Volume")
                            .font(.system(size: 9.5, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - Dynamic Titles & Subtitles
    private var modeTitle: String {
        switch state.mode {
        case .media:
            return state.mediaTitle
        case .call:
            return state.callerName
        case .timer:
            return "Focus Session"
        case .stopwatch:
            return "Stopwatch"
        case .battery:
            return "iPhone 11 Battery"
        case .silent:
            return state.isSilentOn ? "Silent Mode" : "Ring Mode"
        }
    }

    private var modeSubtitle: String {
        switch state.mode {
        case .media:
            return state.mediaArtist
        case .call:
            return state.isCallActive ? "Connected • In Call" : state.callerSubtitle
        case .timer:
            return "\(state.timerFormatted) remaining"
        case .stopwatch:
            return state.stopwatchFormatted
        case .battery:
            return state.isCharging ? "Charging • \(state.batteryPercentage)%" : "\(state.batteryPercentage)% Remaining"
        case .silent:
            return state.isSilentOn ? "Mute Enabled" : "Sound Enabled"
        }
    }

    private var subtitleColor: Color {
        switch state.mode {
        case .media:
            return state.theme.color
        case .call:
            return state.isCallActive ? Color.green : Color.orange
        case .timer:
            return Color.orange
        case .stopwatch:
            return state.theme.color
        case .battery:
            return batteryColor
        case .silent:
            return state.isSilentOn ? Color.red : Color.green
        }
    }

    // MARK: - Leading Accessory
    @ViewBuilder
    private var leadingAccessory: some View {
        switch state.mode {
        case .media:
            if let artwork = nowPlaying.artworkImage {
                Image(uiImage: artwork)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 25, height: 25)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(state.theme.color)
                        .frame(width: 25, height: 25)
                    Image(systemName: "music.note")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.black)
                }
            }

        case .call:
            ZStack {
                Circle()
                    .fill(state.isCallActive ? Color.green.opacity(0.25) : Color.green)
                    .frame(width: 25, height: 25)
                Image(systemName: "phone.fill")
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(state.isCallActive ? Color.green : Color.white)
            }

        case .timer:
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.22))
                    .frame(width: 25, height: 25)
                Image(systemName: "timer")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.orange)
            }

        case .stopwatch:
            ZStack {
                Circle()
                    .fill(state.theme.color.opacity(0.22))
                    .frame(width: 25, height: 25)
                Image(systemName: "stopwatch.fill")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(state.theme.color)
            }

        case .battery:
            ZStack {
                Circle()
                    .fill(batteryColor.opacity(0.22))
                    .frame(width: 25, height: 25)
                Image(systemName: state.isCharging ? "bolt.fill" : "battery.100")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(batteryColor)
            }

        case .silent:
            ZStack {
                Circle()
                    .fill((state.isSilentOn ? Color.red : Color.green).opacity(0.22))
                    .frame(width: 25, height: 25)
                Image(systemName: state.isSilentOn ? "bell.slash.fill" : "bell.fill")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(state.isSilentOn ? Color.red : Color.green)
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
        case .media:
            EqualizerWaveformView(color: state.theme.color)

        case .call:
            if state.isCallActive {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 8, height: 8)
            } else {
                HStack(spacing: 5) {
                    Image(systemName: "phone.down.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.red)
                    Image(systemName: "phone.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                }
            }

        case .timer:
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 2.2)
                    .frame(width: 20, height: 20)
                Circle()
                    .trim(from: 0, to: CGFloat(max(0.04, min(1.0, (state.totalSeconds - state.remainingSeconds) / max(1.0, state.totalSeconds)))))
                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .frame(width: 20, height: 20)
            }

        case .stopwatch:
            HStack(spacing: 3) {
                Image(systemName: state.isStopwatchRunning ? "record.circle.fill" : "pause.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(state.theme.color)
            }

        case .battery:
            HStack(spacing: 2) {
                Text("\(state.batteryPercentage)%")
                    .font(.system(size: 10.5, weight: .bold, design: .rounded))
                    .foregroundColor(batteryColor)
                Image(systemName: state.isCharging ? "bolt.fill" : "battery.25")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(batteryColor)
            }

        case .silent:
            Text(state.isSilentOn ? "MUTED" : "ON")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(state.isSilentOn ? Color.red : Color.green)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background((state.isSilentOn ? Color.red : Color.green).opacity(0.18))
                .clipShape(Capsule())
        }
    }
}

// MARK: - Animated Equalizer Waveform
struct EqualizerWaveformView: View {
    let color: Color
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2.0) {
            bar(minHeight: 4, maxHeight: 15, delay: 0.0)
            bar(minHeight: 13, maxHeight: 5, delay: 0.12)
            bar(minHeight: 5, maxHeight: 16, delay: 0.06)
            bar(minHeight: 12, maxHeight: 4, delay: 0.18)
        }
        .frame(height: 16)
        .onAppear {
            animating = true
        }
    }

    private func bar(minHeight: CGFloat, maxHeight: CGFloat, delay: Double) -> some View {
        RoundedRectangle(cornerRadius: 1.0)
            .fill(color)
            .frame(width: 2.2, height: animating ? maxHeight : minHeight)
            .animation(
                Animation.easeInOut(duration: 0.38)
                    .repeatForever(autoreverses: true)
                    .delay(delay),
                value: animating
            )
    }
}
