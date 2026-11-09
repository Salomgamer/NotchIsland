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
        host.view.isUserInteractionEnabled = true
        self.hostingController = host

        // Video call view controller for PiP
        let videoCallVC = AVPictureInPictureVideoCallViewController()
        videoCallVC.preferredContentSize = initialSize
        videoCallVC.view.backgroundColor = .clear
        videoCallVC.view.isOpaque = false
        videoCallVC.view.isUserInteractionEnabled = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handlePiPTap))
        tap.cancelsTouchesInView = false
        videoCallVC.view.addGestureRecognizer(tap)

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


    func purgeBackdropAndShadows() {
        guard let videoCallVC = pipVideoCallVC else { return }
        videoCallVC.view.backgroundColor = .clear
        videoCallVC.view.isOpaque = false
        videoCallVC.view.layer.backgroundColor = UIColor.clear.cgColor

        hostingController?.view.backgroundColor = .clear
        hostingController?.view.isOpaque = false
        hostingController?.view.layer.backgroundColor = UIColor.clear.cgColor

        var current: UIView? = videoCallVC.view
        while let parent = current?.superview {
            parent.backgroundColor = .clear
            parent.isOpaque = false
            parent.layer.backgroundColor = UIColor.clear.cgColor
            parent.clipsToBounds = false

            for subview in parent.subviews {
                if let visualEffect = subview as? UIVisualEffectView {
                    visualEffect.isHidden = true
                    visualEffect.alpha = 0
                }
            }
            current = parent
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

    @objc private func handlePiPTap() {
        if !IslandState.shared.isExpanded {
            IslandState.shared.expand()
        }
    }

    // MARK: - AVPictureInPictureControllerDelegate
    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        let state = IslandState.shared

        if state.bubbleTouchAction == .openApp || (state.bubbleTouchAction == .smartAdaptive && state.hasActiveExternalApp) {
            // Immediately open the app of whatever is currently happening!
            completionHandler(true)
            state.openActiveApp()

            // Keep PiP floating continuously over the opened active app
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { [weak self] in
                if self?.isPiPActive == false {
                    self?.pipController?.startPictureInPicture()
                }
            }
        } else {
            // Expand the Dynamic Island in-place without opening the full settings lab
            completionHandler(true)
            HapticService.shared.medium()
            withAnimation(.spring(response: state.animationProfile.response, dampingFraction: state.animationProfile.damping)) {
                state.isExpandedViaPiPTap = true
                state.isExpanded = true
            }
            updateSize(width: state.islandWidth, height: state.islandHeight)
        }
    }

    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async { self.isPiPActive = true }
    }

    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
        DispatchQueue.main.async { self.isPiPActive = false }
    }
}
