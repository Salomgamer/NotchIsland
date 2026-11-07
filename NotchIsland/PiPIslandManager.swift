import AVKit
import SwiftUI

class PiPIslandManager: NSObject, ObservableObject, AVPictureInPictureControllerDelegate {
    static let shared = PiPIslandManager()

    var pipController: AVPictureInPictureController?
    var pipVideoCallVC: AVPictureInPictureVideoCallViewController?
    var hostingController: UIHostingController<FloatingIslandView>?
    let anchorSourceView = UIView()

    @Published var isPiPActive: Bool = false
    @Published var isPossible: Bool = false

    override init() {
        super.init()
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
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            print("Picture in Picture is not supported on this device/environment.")
            return
        }

        // Setup anchor source view inside container
        anchorSourceView.removeFromSuperview()
        containerView.addSubview(anchorSourceView)
        anchorSourceView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            anchorSourceView.topAnchor.constraint(equalTo: containerView.topAnchor),
            anchorSourceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            anchorSourceView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            anchorSourceView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])

        let state = IslandState.shared
        let initialSize = CGSize(width: state.islandWidth, height: state.islandHeight)

        // Hosting controller for the floating island content
        let islandView = FloatingIslandView(state: state)
        let host = UIHostingController(rootView: islandView)
        host.view.backgroundColor = .clear
        host.view.isOpaque = false
        self.hostingController = host

        // Video call view controller for PiP
        let videoCallVC = AVPictureInPictureVideoCallViewController()
        videoCallVC.preferredContentSize = initialSize
        videoCallVC.view.backgroundColor = .clear
        videoCallVC.view.isOpaque = false

        videoCallVC.addChild(host)
        videoCallVC.view.addSubview(host.view)

        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: videoCallVC.view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: videoCallVC.view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: videoCallVC.view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: videoCallVC.view.trailingAnchor)
        ])

        host.didMove(toParent: videoCallVC)
        self.pipVideoCallVC = videoCallVC

        let source = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: anchorSourceView,
            contentViewController: videoCallVC
        )

        let controller = AVPictureInPictureController(contentSource: source)
        controller.delegate = self
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        self.pipController = controller

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isPossible = controller.isPictureInPicturePossible
        }
    }

    func updateSize(width: CGFloat, height: CGFloat) {
        let newSize = CGSize(width: width, height: height)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pipVideoCallVC?.preferredContentSize = newSize
        }
    }

    func start() {
        configureAudioSession()
        guard let controller = pipController else {
            print("PiP controller not initialized.")
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
