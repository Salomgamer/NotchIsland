import Foundation
import AVFoundation

class TorchService: ObservableObject {
    static let shared = TorchService()

    @Published var isTorchOn: Bool = false
    @Published var hasTorch: Bool = false
    @Published var isSOSActive: Bool = false
    @Published var torchLevel: Float = 1.0

    private var sosTimer: Timer?
    private var sosStep: Int = 0

    private init() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            self.hasTorch = true
            self.isTorchOn = (device.torchMode == .on)
        }
    }

    func toggleTorch() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .on {
                    device.torchMode = .off
                    self.isTorchOn = false
                } else {
                    try device.setTorchModeOn(level: self.torchLevel)
                    self.isTorchOn = true
                }
                device.unlockForConfiguration()
            } catch {
                print("[TorchService] Error toggling torch: \(error.localizedDescription)")
            }
        } else {
            self.isTorchOn.toggle()
        }
        HapticService.shared.medium()
        IslandState.shared.triggerNotification(
            title: isTorchOn ? "Flashlight On" : "Flashlight Off",
            subtitle: isTorchOn ? "\(Int(torchLevel * 100))% Brightness • Active" : "Torch disabled",
            icon: isTorchOn ? "flashlight.on.fill" : "flashlight.off.fill",
            color: isTorchOn ? .yellow : .gray
        )
        IslandState.shared.evaluateActiveMode()
    }

    func setTorchLevel(_ level: Float) {
        let clamped = max(0.1, min(1.0, level))
        self.torchLevel = clamped
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: clamped)
                self.isTorchOn = true
                device.unlockForConfiguration()
            } catch {
                print("[TorchService] Error setting torch level: \(error.localizedDescription)")
            }
        } else {
            self.isTorchOn = true
        }
        HapticService.shared.light()
        IslandState.shared.evaluateActiveMode()
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
        IslandState.shared.evaluateActiveMode()
    }

    private func tickSOS() {
        sosStep = (sosStep + 1) % 2
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            try? device.lockForConfiguration()
            if sosStep == 1 {
                try? device.setTorchModeOn(level: 1.0)
                self.isTorchOn = true
            } else {
                device.torchMode = .off
                self.isTorchOn = false
            }
            device.unlockForConfiguration()
        } else {
            self.isTorchOn = (sosStep == 1)
        }
    }
}
