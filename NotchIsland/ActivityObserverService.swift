import Foundation
import UIKit
import AVFoundation
import SwiftUI

class ActivityObserverService: ObservableObject {
    static let shared = ActivityObserverService()

    private var observers: [NSObjectProtocol] = []

    private init() {}

    func startMonitoring() {
        stopMonitoring()

        // 1. Screenshot Detection
        let screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { _ in
            HapticService.shared.medium()
            IslandState.shared.triggerNotification(
                title: "Screenshot Captured",
                subtitle: "Saved to Photos • Full Resolution",
                icon: "camera.fill",
                color: Color(red: 0.0, green: 0.85, blue: 1.0)
            )
        }
        observers.append(screenshotObserver)

        // 2. Audio Route Change (AirPods / Headphones / Bluetooth)
        let audioRouteObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { notif in
            guard let userInfo = notif.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }

            switch reason {
            case .newDeviceAvailable:
                HapticService.shared.success()
                let currentRoute = AVAudioSession.sharedInstance().currentRoute
                let portName = currentRoute.outputs.first?.portName ?? "Audio Device"
                let isAirPods = portName.localizedCaseInsensitiveContains("AirPods")
                IslandState.shared.triggerNotification(
                    title: portName,
                    subtitle: "Connected • Active Audio Route",
                    icon: isAirPods ? "airpodspro" : "headphones",
                    color: Color(red: 0.18, green: 0.84, blue: 0.38)
                )

            case .oldDeviceUnavailable:
                HapticService.shared.light()
                IslandState.shared.triggerNotification(
                    title: "Audio Disconnected",
                    subtitle: "Switched to Built-in Speaker",
                    icon: "speaker.wave.1.fill",
                    color: .gray
                )

            default:
                break
            }
        }
        observers.append(audioRouteObserver)

        // 3. Thermal State Monitoring
        let thermalObserver = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            switch ProcessInfo.processInfo.thermalState {
            case .serious, .critical:
                HapticService.shared.warning()
                IslandState.shared.triggerNotification(
                    title: "High Temperature",
                    subtitle: "iPhone needs to cool down before using",
                    icon: "thermometer.sun.fill",
                    color: .red
                )
            case .nominal, .fair:
                break
            @unknown default:
                break
            }
        }
        observers.append(thermalObserver)
    }

    func stopMonitoring() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }

    deinit {
        stopMonitoring()
    }
}
