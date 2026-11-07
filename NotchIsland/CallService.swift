import Foundation
import CallKit
import Combine
import SwiftUI

class CallService: NSObject, ObservableObject, CXCallObserverDelegate {
    static let shared = CallService()

    private let callObserver = CXCallObserver()
    @Published var hasActiveCall: Bool = false
    @Published var isIncoming: Bool = false
    @Published var activeCallerName: String = "Incoming Call"
    @Published var activeCallerSubtitle: String = "Cellular • Audio"
    @Published var callDurationSeconds: Int = 0

    private var callTimer: Timer?

    override private init() {
        super.init()
    }

    func startMonitoring() {
        callObserver.setDelegate(self, queue: DispatchQueue.main)
        // Check current call status on start
        for call in callObserver.calls {
            evaluateCall(call)
        }
    }

    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        DispatchQueue.main.async { [weak self] in
            self?.evaluateCall(call)
        }
    }

    private func evaluateCall(_ call: CXCall) {
        if call.hasEnded {
            // Call ended or declined
            stopCallTimer()
            hasActiveCall = false
            isIncoming = false
            HapticService.shared.stopCallRingtone()

            IslandState.shared.callerName = "Call Ended"
            IslandState.shared.callerSubtitle = "Disconnected"
            IslandState.shared.isCallActive = false

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                if !self.hasActiveCall && !self.isIncoming {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                        IslandState.shared.isExpanded = false
                        IslandState.shared.evaluateActiveMode()
                    }
                    PiPIslandManager.shared.updateSize(
                        width: IslandState.shared.islandWidth,
                        height: IslandState.shared.islandHeight
                    )
                }
            }
        } else if call.hasConnected {
            // Call answered / connected
            stopCallTimer()
            HapticService.shared.stopCallRingtone()
            hasActiveCall = true
            isIncoming = false
            callDurationSeconds = 0

            IslandState.shared.isCallActive = true
            IslandState.shared.callerName = call.isOutgoing ? "Outgoing Call" : "Connected Call"
            IslandState.shared.callerSubtitle = "00:00"
            IslandState.shared.setMode(.call)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                IslandState.shared.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(
                width: IslandState.shared.islandWidth,
                height: IslandState.shared.islandHeight
            )

            startCallTimer()
        } else if call.isOutgoing {
            // Calling out
            hasActiveCall = true
            isIncoming = false
            IslandState.shared.isCallActive = true
            IslandState.shared.callerName = "Calling..."
            IslandState.shared.callerSubtitle = "Dialing"
            IslandState.shared.setMode(.call)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                IslandState.shared.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(
                width: IslandState.shared.islandWidth,
                height: IslandState.shared.islandHeight
            )
        } else {
            // Incoming Call Ringing!
            hasActiveCall = true
            isIncoming = true
            IslandState.shared.callerName = "Incoming Call"
            IslandState.shared.callerSubtitle = "Cellular • Audio"
            IslandState.shared.isCallActive = false
            IslandState.shared.setMode(.call)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
                IslandState.shared.isExpanded = true
            }
            PiPIslandManager.shared.updateSize(
                width: IslandState.shared.islandWidth,
                height: IslandState.shared.islandHeight
            )

            HapticService.shared.startCallRingtone()
        }
    }

    private func startCallTimer() {
        callTimer?.invalidate()
        callTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, self.hasActiveCall else { return }
            self.callDurationSeconds += 1
            let m = self.callDurationSeconds / 60
            let s = self.callDurationSeconds % 60
            IslandState.shared.callerSubtitle = String(format: "%02d:%02d", m, s)
        }
    }

    private func stopCallTimer() {
        callTimer?.invalidate()
        callTimer = nil
    }
}
