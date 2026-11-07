import UIKit
import AudioToolbox

class HapticService {
    static let shared = HapticService()

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
        lightImpact.impactOccurred()
    }

    func medium() {
        mediumImpact.impactOccurred()
    }

    func heavy() {
        heavyImpact.impactOccurred()
    }

    func selection() {
        selectionFeedback.selectionChanged()
    }

    func chargeHaptic() {
        mediumImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [weak self] in
            self?.heavyImpact.impactOccurred()
        }
    }

    func doubleTapHaptic() {
        lightImpact.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
            self?.mediumImpact.impactOccurred()
        }
    }

    func silentSwitchHaptic(isSilent: Bool) {
        if isSilent {
            heavyImpact.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) { [weak self] in
                self?.heavyImpact.impactOccurred()
            }
        } else {
            mediumImpact.impactOccurred()
        }
    }

    func success() {
        notificationFeedback.notificationOccurred(.success)
    }

    func warning() {
        notificationFeedback.notificationOccurred(.warning)
    }

    func error() {
        notificationFeedback.notificationOccurred(.error)
    }

    func clickSound() {
        AudioServicesPlaySystemSound(1104)
    }
}
