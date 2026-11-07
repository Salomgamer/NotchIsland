import Foundation
import UIKit
import Combine
import MediaPlayer

class NowPlayingService: ObservableObject {
    static let shared = NowPlayingService()

    @Published var title: String = "No Music Playing"
    @Published var artist: String = "Play Spotify or Music"
    @Published var isPlaying: Bool = false
    @Published var artworkImage: UIImage?

    private var pollTimer: Timer?

    // Function signature for MRMediaRemoteGetNowPlayingInfo
    typealias MRGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]?) -> Void) -> Void
    typealias MRRegisterNotificationsFunction = @convention(c) (DispatchQueue) -> Void

    private var getNowPlayingInfoFunc: MRGetNowPlayingInfoFunction?

    init() {
        loadMediaRemote()
        startMonitoring()
    }

    private func loadMediaRemote() {
        let path = "/System/Library/PrivateFrameworks/MediaRemote.framework"
        guard let bundleURL = URL(string: "file://\(path)"),
              let bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL as CFURL) else {
            print("[NowPlayingService] MediaRemote framework bundle unavailable, using MediaPlayer fallback.")
            return
        }

        if let ptr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
            self.getNowPlayingInfoFunc = unsafeBitCast(ptr, to: MRGetNowPlayingInfoFunction.self)
        }

        if let regPtr = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString) {
            let registerFunc = unsafeBitCast(regPtr, to: MRRegisterNotificationsFunction.self)
            registerFunc(DispatchQueue.main)
        }
    }

    func startMonitoring() {
        // Listen to MediaRemote system notifications (fires when Spotify / EeveeSpotify changes track)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(queryNowPlaying),
            name: NSNotification.Name("kMRMediaRemoteNowPlayingInfoDidChangeNotification"),
            object: nil
        )

        // Continuous fast poll (every 1.0 second) to ensure instant sync
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

                // If MediaRemote returned empty, check MPMusicPlayerController
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
            // Idle state when nothing is playing
            if self.title.isEmpty || self.title == "Starboy" {
                self.title = "No Music Playing"
                self.artist = "Play track in Spotify"
                self.isPlaying = false
            }
        }
    }
}
