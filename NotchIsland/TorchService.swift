import Foundation
import AVFoundation

class TorchService: ObservableObject {
    static let shared = TorchService()

    @Published var isTorchOn: Bool = false
    @Published var hasTorch: Bool = false
    @Published var isSOSActive: Bool = false

    private var sosTimer: Timer?
    private var sosStep: Int = 0

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

    func toggleSOS() {
        if isSOSActive {
            stopSOS()
        } else {
            startSOS()
        }
    }

    func startSOS() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        isSOSActive = true
        sosStep = 0
        HapticService.shared.heavy()
        IslandState.shared.triggerNotification(
            title: "SOS Beacon Active",
            subtitle: "Emergency Morse Strobe Blinking",
            icon: "exclamationmark.shield.fill",
            color: .red
        )
        sosTimer?.invalidate()
        sosTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.tickSOS()
        }
    }

    func stopSOS() {
        sosTimer?.invalidate()
        sosTimer = nil
        isSOSActive = false
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        }
        isTorchOn = false
        HapticService.shared.medium()
        IslandState.shared.triggerNotification(
            title: "SOS Beacon Stopped",
            subtitle: "Flashlight Off",
            icon: "flashlight.off.fill",
            color: .gray
        )
    }

    private func tickSOS() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        sosStep = (sosStep + 1) % 2
        try? device.lockForConfiguration()
        if sosStep == 1 {
            try? device.setTorchModeOn(level: 1.0)
            self.isTorchOn = true
        } else {
            device.torchMode = .off
            self.isTorchOn = false
        }
        device.unlockForConfiguration()
    }
}
