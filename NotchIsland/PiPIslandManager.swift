import AVKit
import SwiftUI

class PiPIslandManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate {
    static let shared = PiPIslandManager()

    private var pipController: AVPictureInPictureController?
    private var pipVideoCallVC: AVPictureInPictureVideoCallViewController?
    private var hostingController: UIHostingController<FloatingIslandView>?
    private var anchorSourceView = UIView()

    @Published var isPiPActive: Bool = false

    override init() {
        super.init()
        configureAudioSession()
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("Audio session configuration error: \(error.localizedDescription)")
        }
    }

    func attach(to containerView: UIView) {
        // Prevent duplicate attachments
        if anchorSourceView.superview != nil { return }

        anchorSourceView.frame = CGRect(x: 0, y: 0, width: 216, height: 48)
        anchorSourceView.backgroundColor = .clear
        containerView.addSubview(anchorSourceView)

        let islandView = FloatingIslandView(state: IslandState.shared)
        let host = UIHostingController(rootView: islandView)
        host.view.frame = anchorSourceView.bounds
        host.view.backgroundColor = .clear
        self.hostingController = host

        let videoCallVC = AVPictureInPictureVideoCallViewController()
        videoCallVC.preferredContentSize = CGSize(width: 216, height: 48)
        videoCallVC.view.addSubview(host.view)
        self.pipVideoCallVC = videoCallVC

        let source = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: anchorSourceView,
            contentViewController: videoCallVC
        )

        let controller = AVPictureInPictureController(contentSource: source)
        controller.delegate = self
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        self.pipController = controller
    }

    func start() {
        guard let controller = pipController, controller.isPictureInPicturePossible else {
            print("PiP is not currently possible. Ensure device supports video PiP.")
            return
        }
        controller.startPictureInPicture()
    }

    func stop() {
        pipController?.stopPictureInPicture()
    }

    func toggle() {
        if isPiPActive {
            stop()
        } else {
            start()
        }
    }

    // MARK: - AVPictureInPictureControllerDelegate
    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async { self.isPiPActive = true }
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async { self.isPiPActive = false }
    }
}
