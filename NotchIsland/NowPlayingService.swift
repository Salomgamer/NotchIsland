import Foundation
import UIKit
import SwiftUI
import Combine
import MediaPlayer
import AVFoundation

enum AudioRouteType: String {
    case airPods = "AirPods"
    case airPodsPro = "AirPods Pro"
    case airPodsMax = "AirPods Max"
    case beats = "Beats"
    case headphones = "Headphones"
    case carPlay = "CarPlay"
    case airPlay = "AirPlay"
    case speaker = "iPhone Speaker"

    var iconName: String {
        switch self {
        case .airPods: return "airpods"
        case .airPodsPro: return "airpodspro"
        case .airPodsMax: return "airpodsmax"
        case .beats: return "headphones"
        case .headphones: return "headphones"
        case .carPlay: return "car.fill"
        case .airPlay: return "airplayaudio"
        case .speaker: return "speaker.wave.2.fill"
        }
    }

    var isExternalOrHeadphones: Bool {
        return self != .speaker
    }
}

class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = "No Music Playing"
    @Published var artist: String = "Play Spotify, YouTube, Safari, or Stremio"
    @Published var sourceAppName: String = "Media"
    @Published var isPlaying: Bool = false
    @Published var artworkImage: UIImage?
    @Published var artworkAccentColor: Color?
    @Published var hasMediaPermission: Bool = false
    @Published var lastSyncTime: Date = Date()

    // Real-Time Playback Progress
    @Published var trackDuration: Double = 0.0
    @Published var trackElapsedTime: Double = 0.0
    @Published var trackProgress: Double = 0.35

    // Audio Output Route & Accessories
    @Published var currentRouteType: AudioRouteType = .speaker
    @Published var currentRouteName: String = "iPhone Speaker"
    private var previousRouteName: String = "iPhone Speaker"

    var elapsedFormatted: String {
        guard trackDuration > 0 else { return "0:00" }
        let m = Int(trackElapsedTime) / 60
        let s = Int(trackElapsedTime) % 60
        return String(format: "%d:%02d", m, s)
    }

    var remainingFormatted: String {
        guard trackDuration > 0 else { return "-0:00" }
        let remaining = max(0, trackDuration - trackElapsedTime)
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        return String(format: "-%d:%02d", m, s)
    }

    private var previousTrackTitle: String = ""
    private var pollTimer: Timer?

    typealias MRGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]?) -> Void) -> Void
    typealias MRRegisterNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    typealias MRGetIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
    typealias MRSendCommandFunction = @convention(c) (UInt32, [String: Any]?) -> Bool

    private var getNowPlayingInfoFunc: MRGetNowPlayingInfoFunction?
    private var getIsPlayingFunc: MRGetIsPlayingFunction?
    private var sendCommandFunc: MRSendCommandFunction?

    init() {
        checkPermissions()
        resolveMediaRemote()
        setupAudioSessionObserver()
        startMonitoring()
    }

    func checkPermissions() {
        hasMediaPermission = (MPMediaLibrary.authorizationStatus() == .authorized)
    }

    func requestAllPermissions(completion: @escaping () -> Void = {}) {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.hasMediaPermission = (status == .authorized)
                self?.queryNowPlaying()
                completion()
            }
        }
    }

    private func resolveMediaRemote() {
        var handle = dlopen("/System/Library/PrivateFrameworks/MediaRemote.framework/MediaRemote", RTLD_NOW)
        if handle == nil {
            handle = dlopen(nil, RTLD_NOW)
        }

        guard let validHandle = handle else {
            print("[NowPlayingService] Could not resolve MediaRemote handle")
            return
        }

        if let symInfo = dlsym(validHandle, "MRMediaRemoteGetNowPlayingInfo") {
            self.getNowPlayingInfoFunc = unsafeBitCast(symInfo, to: MRGetNowPlayingInfoFunction.self)
        }

        if let symIsPlaying = dlsym(validHandle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying") {
            self.getIsPlayingFunc = unsafeBitCast(symIsPlaying, to: MRGetIsPlayingFunction.self)
        }

        if let symCmd = dlsym(validHandle, "MRMediaRemoteSendCommand") {
            self.sendCommandFunc = unsafeBitCast(symCmd, to: MRSendCommandFunction.self)
        }

        if let symReg = dlsym(validHandle, "MRMediaRemoteRegisterForNowPlayingNotifications") {
            let registerFunc = unsafeBitCast(symReg, to: MRRegisterNotificationsFunction.self)
            registerFunc(DispatchQueue.main)
        }
    }

    private func setupAudioSessionObserver() {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.silenceSecondaryAudioHintNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.queryNowPlaying()
        }

        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notif in
            self?.handleAudioRouteChange(notif)
        }

        detectCurrentAudioRoute(notifyIfNew: false)
    }

    private func handleAudioRouteChange(_ notif: Notification) {
        detectCurrentAudioRoute(notifyIfNew: true)
    }

    func detectCurrentAudioRoute(notifyIfNew: Bool) {
        let route = AVAudioSession.sharedInstance().currentRoute

        var detectedName = "iPhone Speaker"
        var detectedType: AudioRouteType = .speaker

        for output in route.outputs {
            let name = output.portName
            let portType = output.portType

            if portType == .bluetoothA2DP || portType == .bluetoothLE || portType == .bluetoothHFP || portType == .headphones {
                detectedName = name
                let lower = name.lowercased()
                if lower.contains("pro") {
                    detectedType = .airPodsPro
                } else if lower.contains("max") {
                    detectedType = .airPodsMax
                } else if lower.contains("airpod") {
                    detectedType = .airPods
                } else if lower.contains("beats") {
                    detectedType = .beats
                } else {
                    detectedType = .headphones
                }
                break
            } else if portType == .airPlay {
                detectedName = name
                detectedType = .airPlay
                break
            } else if portType == .carAudio {
                detectedName = name
                detectedType = .carPlay
                break
            }
        }

        let changed = (self.currentRouteName != detectedName)
        self.currentRouteName = detectedName
        self.currentRouteType = detectedType

        if changed && notifyIfNew {
            if detectedType.isExternalOrHeadphones {
                IslandState.shared.triggerNotification(
                    title: detectedName,
                    subtitle: "\(detectedType.rawValue) Connected • Stereo Audio",
                    icon: detectedType.iconName,
                    color: Color(red: 0.18, green: 0.84, blue: 0.38)
                )
            } else if previousRouteName != "iPhone Speaker" {
                IslandState.shared.triggerNotification(
                    title: "Audio Disconnected",
                    subtitle: "Switched to iPhone Speaker",
                    icon: "speaker.wave.1.fill",
                    color: .orange
                )
            }
            self.previousRouteName = detectedName
        }
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryNowPlaying),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil
        )

        pollTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { [weak self] _ in
            self?.tickPlayback()
            self?.queryNowPlaying()
        }

        queryNowPlaying()
    }

    private func tickPlayback() {
        if isPlaying && trackDuration > 0 && trackElapsedTime < trackDuration {
            trackElapsedTime += 0.8
            trackProgress = min(1.0, max(0.0, trackElapsedTime / trackDuration))
        }
    }

    @objc func queryNowPlaying() {
        let isAudioActive = AVAudioSession.sharedInstance().isOtherAudioPlaying

        if let getInfo = self.getNowPlayingInfoFunc {
            getInfo(DispatchQueue.main) { [weak self] infoDict in
                guard let self = self else { return }

                if let dict = infoDict {
                    let trackTitle = (dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String)
                        ?? (dict["title"] as? String)
                        ?? (dict["kMRMediaRemoteNowPlayingInfoName"] as? String)

                    let trackArtist = (dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String)
                        ?? (dict["artist"] as? String)
                        ?? (dict["kMRMediaRemoteNowPlayingInfoAlbum"] as? String)
                        ?? (dict["album"] as? String)

                    let detectedApp = self.extractSourceApp(from: dict)
                    self.sourceAppName = detectedApp

                    let rate = (dict["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double) ?? 1.0

                    // Duration and Elapsed Time
                    if let dur = (dict["kMRMediaRemoteNowPlayingInfoDuration"] as? Double) ?? (dict["duration"] as? Double), dur > 0 {
                        self.trackDuration = dur
                    }
                    if let el = (dict["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double) ?? (dict["elapsedTime"] as? Double) {
                        self.trackElapsedTime = el
                        if self.trackDuration > 0 {
                            self.trackProgress = min(1.0, max(0.0, el / self.trackDuration))
                        }
                    }

                    if let t = trackTitle, !t.isEmpty {
                        let isNewTrack = (self.previousTrackTitle != t) && !self.previousTrackTitle.isEmpty
                        self.previousTrackTitle = t

                        self.title = t
                        self.artist = trackArtist ?? detectedApp
                        self.isPlaying = (rate > 0.0) || isAudioActive
                        self.lastSyncTime = Date()

                        if let rawData = (dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data) ?? (dict["artworkData"] as? Data),
                           let img = UIImage(data: rawData) {
                            self.artworkImage = img
                            self.extractAccentColor(from: img)
                        }

                        // Trigger auto-expand on track change
                        if isNewTrack {
                            IslandState.shared.triggerNotification(
                                title: t,
                                subtitle: "\(trackArtist ?? detectedApp) • \(detectedApp)",
                                icon: "music.note",
                                color: self.artworkAccentColor
                            )
                        }
                        return
                    }
                }

                // If media metadata is not exposed, but audio is streaming (YouTube, Safari, Stremio)
                if isAudioActive {
                    if self.title == "No Music Playing" || self.title.isEmpty {
                        self.title = "Live Audio Playing"
                        self.artist = "YouTube / Stremio / Safari"
                        self.sourceAppName = "Media Stream"
                    }
                    self.isPlaying = true
                    return
                }

                self.checkMPMusicFallback(isAudioActive: isAudioActive)
            }
        } else {
            checkMPMusicFallback(isAudioActive: isAudioActive)
        }
    }

    private func extractSourceApp(from dict: [String: Any]) -> String {
        if let client = dict["kMRMediaRemoteNowPlayingInfoClientProperties"] as? [String: Any] {
            if let displayName = client["displayName"] as? String, !displayName.isEmpty {
                return displayName
            }
            if let bundleId = client["bundleIdentifier"] as? String {
                return parseAppName(bundleId)
            }
        }
        if let bundleId = dict["kMRMediaRemoteNowPlayingApplicationBundleIdentifier"] as? String {
            return parseAppName(bundleId)
        }
        if let appName = dict["kMRMediaRemoteNowPlayingApplicationDisplayName"] as? String {
            return appName
        }
        return "Spotify"
    }

    private func parseAppName(_ bundleId: String) -> String {
        let b = bundleId.lowercased()
        if b.contains("youtube") { return "YouTube" }
        if b.contains("stremio") { return "Stremio" }
        if b.contains("safari") { return "Safari" }
        if b.contains("spotify") { return "Spotify" }
        if b.contains("netflix") { return "Netflix" }
        if b.contains("soundcloud") { return "SoundCloud" }
        if b.contains("music") { return "Apple Music" }
        if b.contains("podcast") { return "Podcasts" }
        return "Media"
    }

    private func checkMPMusicFallback(isAudioActive: Bool) {
        let player = MPMusicPlayerController.systemMusicPlayer
        if let item = player.nowPlayingItem, let itemTitle = item.title {
            let isNewTrack = (self.previousTrackTitle != itemTitle) && !self.previousTrackTitle.isEmpty
            self.previousTrackTitle = itemTitle

            self.title = itemTitle
            self.artist = item.artist ?? "Apple Music"
            self.sourceAppName = "Apple Music"
            self.isPlaying = (player.playbackState == .playing) || isAudioActive
            self.trackDuration = item.playbackDuration
            self.trackElapsedTime = player.currentPlaybackTime
            if self.trackDuration > 0 {
                self.trackProgress = min(1.0, max(0.0, self.trackElapsedTime / self.trackDuration))
            }

            if let artwork = item.artwork {
                let img = artwork.image(at: CGSize(width: 64, height: 64))
                self.artworkImage = img
                if let validImg = img {
                    self.extractAccentColor(from: validImg)
                }
            }

            if isNewTrack {
                IslandState.shared.triggerNotification(
                    title: itemTitle,
                    subtitle: item.artist ?? "Apple Music",
                    icon: "music.note",
                    color: self.artworkAccentColor
                )
            }
        } else if isAudioActive {
            if self.title == "No Music Playing" || self.title.isEmpty {
                self.title = "Live Audio Playing"
                self.artist = "YouTube / Stremio / Safari"
                self.sourceAppName = "Media Stream"
            }
            self.isPlaying = true
        } else {
            self.title = "No Music Playing"
            self.artist = "Play Spotify, YouTube, Safari, or Stremio"
            self.isPlaying = false
            self.artworkImage = nil
            self.artworkAccentColor = nil
            self.previousTrackTitle = ""
            self.trackDuration = 0
            self.trackElapsedTime = 0
            self.trackProgress = 0
        }
    }

    private func extractAccentColor(from image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        var pixelData = [UInt8](repeating: 0, count: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: &pixelData,
            width: 1,
            height: 1,
            bitsPerComponent: 8,
            bytesPerRow: 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))

        let r = Double(pixelData[0]) / 255.0
        let g = Double(pixelData[1]) / 255.0
        let b = Double(pixelData[2]) / 255.0
        DispatchQueue.main.async {
            self.artworkAccentColor = Color(red: r, green: g, blue: b)
        }
    }

    // MARK: - Interactive Playback Commands
    func togglePlayPause() {
        HapticService.shared.medium()
        if let sendCmd = self.sendCommandFunc {
            _ = sendCmd(2, nil) // MRCommandTogglePlayPause = 2
        } else {
            if MPMusicPlayerController.systemMusicPlayer.playbackState == .playing {
                MPMusicPlayerController.systemMusicPlayer.pause()
            } else {
                MPMusicPlayerController.systemMusicPlayer.play()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.queryNowPlaying()
        }
    }

    func nextTrack() {
        HapticService.shared.light()
        if let sendCmd = self.sendCommandFunc {
            _ = sendCmd(4, nil) // MRCommandNextTrack = 4
        } else {
            MPMusicPlayerController.systemMusicPlayer.skipToNextItem()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.queryNowPlaying()
        }
    }

    func previousTrack() {
        HapticService.shared.light()
        if let sendCmd = self.sendCommandFunc {
            _ = sendCmd(5, nil) // MRCommandPreviousTrack = 5
        } else {
            MPMusicPlayerController.systemMusicPlayer.skipToPreviousItem()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.queryNowPlaying()
        }
    }

    func seek(toProgress progress: Double) {
        guard trackDuration > 0 else { return }
        let clamped = max(0.0, min(1.0, progress))
        let targetTime = trackDuration * clamped
        self.trackElapsedTime = targetTime
        self.trackProgress = clamped

        if let sendCmd = self.sendCommandFunc {
            _ = sendCmd(56, ["kMRMediaRemoteOptionPlaybackPosition": targetTime])
        }
        MPMusicPlayerController.systemMusicPlayer.currentPlaybackTime = targetTime
        HapticService.shared.light()
    }
}
