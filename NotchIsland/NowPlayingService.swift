import Foundation
import UIKit
import Combine
import MediaPlayer
import UserNotifications

class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = "No Music Playing"
    @Published var artist: String = "Play Spotify or Apple Music"
    @Published var isPlaying: Bool = false
    @Published var artworkImage: UIImage?
    @Published var hasMediaPermission: Bool = false
    @Published var hasNotificationPermission: Bool = false

    private var pollTimer: Timer?

    typealias MRGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]?) -> Void) -> Void
    typealias MRRegisterNotificationsFunction = @convention(c) (DispatchQueue) -> Void

    private var getNowPlayingInfoFunc: MRGetNowPlayingInfoFunction?

    init() {
        checkPermissions()
        resolveMediaRemote()
        startMonitoring()
    }

    func checkPermissions() {
        hasMediaPermission = (MPMediaLibrary.authorizationStatus() == .authorized)

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasNotificationPermission = (settings.authorizationStatus == .authorized)
            }
        }
    }

    func requestAllPermissions(completion: @escaping () -> Void = {}) {
        // 1. Request Apple Music & Media Library Permission
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.hasMediaPermission = (status == .authorized)
                self?.queryNowPlaying()
            }
        }

        // 2. Request Notification Permission for live updates
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.hasNotificationPermission = granted
                completion()
            }
        }
    }

    private func resolveMediaRemote() {
        // Use dyld shared cache lookup with fallback to global namespace
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

        if let symReg = dlsym(validHandle, "MRMediaRemoteRegisterForNowPlayingNotifications") {
            let registerFunc = unsafeBitCast(symReg, to: MRRegisterNotificationsFunction.self)
            registerFunc(DispatchQueue.main)
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
        if let getInfo = self.getNowPlayingInfoFunc {
            getInfo(DispatchQueue.main) { [weak self] infoDict in
                guard let self = self else { return }

                if let dict = infoDict,
                   let trackTitle = dict["kMRMediaRemoteNowPlayingInfoTitle"] as? String,
                   !trackTitle.isEmpty {

                    let trackArtist = (dict["kMRMediaRemoteNowPlayingInfoArtist"] as? String)
                        ?? (dict["kMRMediaRemoteNowPlayingInfoAlbum"] as? String)
                        ?? "Spotify"

                    self.title = trackTitle
                    self.artist = trackArtist
                    self.isPlaying = true

                    if let rawData = dict["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data,
                       let img = UIImage(data: rawData) {
                        self.artworkImage = img
                    }
                    return
                }

                self.checkMPMusicFallback()
            }
        } else {
            checkMPMusicFallback()
        }
    }

    private func checkMPMusicFallback() {
        let player = MPMusicPlayerController.systemMusicPlayer
        if let item = player.nowPlayingItem, let itemTitle = item.title {
            self.title = itemTitle
            self.artist = item.artist ?? "Music"
            self.isPlaying = player.playbackState == .playing
            if let artwork = item.artwork {
                self.artworkImage = artwork.image(at: CGSize(width: 48, height: 48))
            }
        } else {
            if self.title.isEmpty || self.title == "Starboy" {
                self.title = "No Music Playing"
                self.artist = "Play track in Spotify"
                self.isPlaying = false
            }
        }
    }
}
