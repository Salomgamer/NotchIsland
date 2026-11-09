import UIKit
import AudioToolbox

enum HapticFeedbackStrength: String, CaseIterable, Identifiable {
    case standard = "Apple Default"
    case subtle = "Subtle"
    case heavy = "Firm"
    case muted = "Disabled"

    var id: String { rawValue }
}

class HapticService: ObservableObject {
    static let shared = HapticService()

    @Published var strength: HapticFeedbackStrength = .standard
    @Published var callSoundsEnabled: Bool = false
    @Published var notificationSoundsEnabled: Bool = false

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
    }

    func light() {
        guard strength != .muted else { return }
        lightImpact.impactOccurred()
    }

    func medium() {
        guard strength != .muted else { return }
        if strength == .subtle {
            lightImpact.impactOccurred()
        } else {
            mediumImpact.impactOccurred()
        }
    }

    func heavy() {
        guard strength != .muted else { return }
        if strength == .subtle {
            lightImpact.impactOccurred()
        } else {
            heavyImpact.impactOccurred()
        }
    }

    func selection() {
        guard strength != .muted else { return }
        selectionFeedback.selectionChanged()
    }

    func chargeHaptic() {
        guard strength != .muted else { return }
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.heavy()
        }
    }

    func doubleTapHaptic() {
        guard strength != .muted else { return }
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.medium()
        }
    }

    func heartbeat() {
        guard strength != .muted else { return }
        medium()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.14) { [weak self] in
            self?.heavy()
        }
    }

    func silentSwitchHaptic(isSilent: Bool) {
        guard strength != .muted else { return }
        if isSilent {
            heavy()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
                self?.heavy()
            }
        } else {
            medium()
        }
    }

    func success() {
        guard strength != .muted else { return }
        notificationFeedback.notificationOccurred(.success)
    }

    func warning() {
        guard strength != .muted else { return }
        notificationFeedback.notificationOccurred(.warning)
    }

    func error() {
        guard strength != .muted else { return }
        notificationFeedback.notificationOccurred(.error)
    }

    func clickSound() {
        AudioServicesPlaySystemSound(1104)
    }

    // MARK: - Incoming Call Ringtone & Haptic Pulse
    private var ringtoneTimer: Timer?

    func startCallRingtone() {
        stopCallRingtone()
        playRingPulse()
        ringtoneTimer = Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { [weak self] _ in
            self?.playRingPulse()
        }
    }

    private func playRingPulse() {
        guard strength != .muted else { return }
        heavy()
        if callSoundsEnabled {
            AudioServicesPlaySystemSound(1005) // Standard incoming telephone chime (silent by default)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { [weak self] in
            self?.medium()
        }
    }

    func applePayDoneHaptic() {
        guard strength != .muted else { return }
        notificationFeedback.notificationOccurred(.success)
        AudioServicesPlaySystemSound(1054)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.medium()
        }
    }

    func expandWhooshSound() {
        guard strength != .muted else { return }
        AudioServicesPlaySystemSound(1104)
    }

    func collapseSnapSound() {
        guard strength != .muted else { return }
        AudioServicesPlaySystemSound(1105)
    }

    func faceIDUnlockSound() {
        guard strength != .muted else { return }
        AudioServicesPlaySystemSound(1111)
    }

    func airPodsConnectedSound() {
        guard strength != .muted else { return }
        AudioServicesPlaySystemSound(1008)
    }

    func pongHitHaptic() {
        guard strength != .muted else { return }
        medium()
        AudioServicesPlaySystemSound(1057)
    }

    func companionPurrHaptic() {
        guard strength != .muted else { return }
        light()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.light()
        }
    }

    func stopCallRingtone() {
        ringtoneTimer?.invalidate()
        ringtoneTimer = nil
    }
}
