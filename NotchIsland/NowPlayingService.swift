import Foundation
import UIKit
import Combine
import MediaPlayer
import AVFoundation

class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = "No Music Playing"
    @Published var artist: String = "Play Spotify or Apple Music"
    @Published var isPlaying: Bool = false
    @Published var artworkImage: UIImage?
    @Published var hasMediaPermission: Bool = false
    @Published var lastSyncTime: Date = Date()

    private var pollTimer: Timer?

    typealias MRGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]?) -> Void) -> Void
    typealias MRRegisterNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    typealias MRGetIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void

    private var getNowPlayingInfoFunc: MRGetNowPlayingInfoFunction?
    private var getIsPlayingFunc: MRGetIsPlayingFunction?

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
        // Load MediaRemote from dyld shared cache
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

        if let symReg = dlsym(validHandle, "MRMediaRemoteRegisterForNowPlayingNotifications") {
            let registerFunc = unsafeBitCast(symReg, to: MRRegisterNotificationsFunction.self)
            registerFunc(DispatchQueue.main)
        }
    }

    private func setupAudioSessionObserver() {
        // Listen to system audio interruptions and secondary audio hints
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.silenceSecondaryAudioHintNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.queryNowPlaying()
        }
    }

    func startMonitoring() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryNowPlaying),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil
        )

        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.queryNowPlaying()
        }

        queryNowPlaying()
    }

    @objc func queryNowPlaying() {
        // Check hardware audio session first
        let isAudioActive = AVAudioSession.sharedInstance().isOtherAudioPlaying

        if let getInfo = self.getNowPlayingInfoFunc {
            getInfo(DispatchQueue.main) { [weak self] infoDict in
                guard let self = self else { return }

                if let dict = infoDict {
                    // Check all possible key variants used by MediaRemote and iOS versions
                    let trackTitle = (dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String)
                        ?? (dict["title"] as? String)
                        ?? (dict["kMRMediaRemoteNowPlayingInfoName"] as? String)

                    let trackArtist = (dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String)
                        ?? (dict["artist"] as? String)
                        ?? (dict["kMRMediaRemoteNowPlayingInfoAlbum"] as? String)
                        ?? (dict["album"] as? String)

                    let rate = (dict["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double) ?? 1.0

                    if let t = trackTitle, !t.isEmpty {
                        self.title = t
                        self.artist = trackArtist ?? "Spotify"
                        self.isPlaying = (rate > 0.0) || isAudioActive
                        self.lastSyncTime = Date()

                        if let rawData = (dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data) ?? (dict["artworkData"] as? Data),
                           let img = UIImage(data: rawData) {
                            self.artworkImage = img
                        }
                        return
                    }
                }

                // If MediaRemote returned no title but audio is playing, keep Spotify indicator active
                if isAudioActive {
                    if self.title == "No Music Playing" || self.title.isEmpty {
                        self.title = "Spotify Music Playing"
                        self.artist = "Live Audio Active"
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

    private func checkMPMusicFallback(isAudioActive: Bool) {
        let player = MPMusicPlayerController.systemMusicPlayer
        if let item = player.nowPlayingItem, let itemTitle = item.title {
            self.title = itemTitle
            self.artist = item.artist ?? "Music"
            self.isPlaying = (player.playbackState == .playing) || isAudioActive
            if let artwork = item.artwork {
                self.artworkImage = artwork.image(at: CGSize(width: 48, height: 48))
            }
        } else if isAudioActive {
            if self.title == "No Music Playing" || self.title.isEmpty {
                self.title = "Spotify Audio Playing"
                self.artist = "Live Audio Active"
            }
            self.isPlaying = true
        } else {
            self.title = "No Music Playing"
            self.artist = "Play track in Spotify"
            self.isPlaying = false
            self.artworkImage = nil
        }
    }
}
