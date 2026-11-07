import Foundation
import UIKit
import Combine

class BatteryService: ObservableObject {
    static let shared = BatteryService()

    @Published var percentage: Int = 100
    @Published var isCharging: Bool = false
    @Published var isAccurateHardwareRead: Bool = false

    private var timer: Timer?

    // Function signatures for IOKit power source APIs
    typealias IOPSCopyPowerSourcesInfoFunc = @convention(c) () -> Unmanaged<CFTypeRef>?
    typealias IOPSCopyPowerSourcesListFunc = @convention(c) (CFTypeRef) -> Unmanaged<CFArray>?
    typealias IOPSGetPowerSourceDescriptionFunc = @convention(c) (CFTypeRef, CFTypeRef) -> Unmanaged<CFDictionary>?

    private var copyPowerSourcesInfo: IOPSCopyPowerSourcesInfoFunc?
    private var copyPowerSourcesList: IOPSCopyPowerSourcesListFunc?
    private var getPowerSourceDesc: IOPSGetPowerSourceDescriptionFunc?

    init() {
        resolveIOKit()
        UIDevice.current.isBatteryMonitoringEnabled = true
        updateBattery()

        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBattery()
        }

        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateBattery()
        }

        // Fast 1.0s polling for continuous exact tracking
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateBattery()
        }
    }

    private func resolveIOKit() {
        // Resolve from dynamic namespace
        let handle = dlopen(nil, RTLD_NOW)
        if let sInfo = dlsym(handle, "IOPSCopyPowerSourcesInfo"),
           let sList = dlsym(handle, "IOPSCopyPowerSourcesList"),
           let sDesc = dlsym(handle, "IOPSGetPowerSourceDescription") {
            self.copyPowerSourcesInfo = unsafeBitCast(sInfo, to: IOPSCopyPowerSourcesInfoFunc.self)
            self.copyPowerSourcesList = unsafeBitCast(sList, to: IOPSCopyPowerSourcesListFunc.self)
            self.getPowerSourceDesc = unsafeBitCast(sDesc, to: IOPSGetPowerSourceDescriptionFunc.self)
        }
    }

    func updateBattery() {
        // 1. Attempt exact hardware reading via IOKit
        if let infoFunc = self.copyPowerSourcesInfo,
           let listFunc = self.copyPowerSourcesList,
           let descFunc = self.getPowerSourceDesc {

            if let infoBlob = infoFunc()?.takeRetainedValue(),
               let sources = listFunc(infoBlob)?.takeRetainedValue() as? [CFTypeRef],
               let first = sources.first,
               let desc = descFunc(infoBlob, first)?.takeUnretainedValue() as? [String: Any] {

                if let currentCap = desc["Current Capacity"] as? Int,
                   let maxCap = desc["Max Capacity"] as? Int, maxCap > 0 {
                    let exactPct = Int(round(Double(currentCap) / Double(maxCap) * 100.0))
                    self.percentage = max(1, min(100, exactPct))
                    self.isAccurateHardwareRead = true

                    if let isChargingVal = desc["Is Charging"] as? Bool {
                        self.isCharging = isChargingVal
                    } else if let state = desc["Power Source State"] as? String {
                        self.isCharging = (state == "AC Power")
                    }
                    return
                }
            }
        }

        // 2. Fallback to UIDevice if IOKit is guarded
        UIDevice.current.isBatteryMonitoringEnabled = true
        let raw = UIDevice.current.batteryLevel
        if raw >= 0 {
            self.percentage = Int(round(raw * 100.0))
        }

        let state = UIDevice.current.batteryState
        self.isCharging = (state == .charging || state == .full)
        self.isAccurateHardwareRead = false
    }
}
