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

        if anchorSourceView.superview != nil { return }

        let state = IslandState.shared
        let initialSize = CGSize(width: state.islandWidth, height: state.islandHeight)

        anchorSourceView.frame = CGRect(origin: .zero, size: initialSize)
        anchorSourceView.backgroundColor = .clear
        containerView.addSubview(anchorSourceView)

        let islandView = FloatingIslandView(state: state)
        let host = UIHostingController(rootView: islandView)
        host.view.frame = CGRect(origin: .zero, size: initialSize)
        host.view.backgroundColor = .clear
        self.hostingController = host

        let videoCallVC = AVPictureInPictureVideoCallViewController()
        videoCallVC.preferredContentSize = initialSize

        videoCallVC.addChild(host)
        videoCallVC.view.addSubview(host.view)
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
    }

    func updateSize(width: CGFloat, height: CGFloat) {
        let newSize = CGSize(width: width, height: height)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.anchorSourceView.frame = CGRect(origin: .zero, size: newSize)
            self.hostingController?.view.frame = CGRect(origin: .zero, size: newSize)
            self.pipVideoCallVC?.preferredContentSize = newSize
        }
    }

    func start() {
        configureAudioSession()
        guard let controller = pipController, controller.isPictureInPicturePossible else {
            print("PiP is not currently possible.")
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
