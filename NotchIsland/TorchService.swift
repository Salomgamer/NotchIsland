import Foundation
import AVFoundation

class TorchService: ObservableObject {
    static let shared = TorchService()

    @Published var isTorchOn: Bool = false
    @Published var hasTorch: Bool = false

    private init() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            self.hasTorch = true
            self.isTorchOn = (device.torchMode == .on)
        }
    }

    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            if device.torchMode == .on {
                device.torchMode = .off
                self.isTorchOn = false
                IslandState.shared.triggerNotification(
                    title: "Flashlight Off",
                    subtitle: "Torch disabled",
                    icon: "flashlight.off.fill",
                    color: .gray
                )
            } else {
                try device.setTorchModeOn(level: 1.0)
                self.isTorchOn = true
                IslandState.shared.triggerNotification(
                    title: "Flashlight On",
                    subtitle: "100% Brightness • Active",
                    icon: "flashlight.on.fill",
                    color: .yellow
                )
            }
            device.unlockForConfiguration()
            HapticService.shared.medium()
        } catch {
            print("[TorchService] Error toggling torch: \(error.localizedDescription)")
        }
    }
}
