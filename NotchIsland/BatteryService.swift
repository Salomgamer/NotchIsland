import Foundation
import UIKit
import Combine

class BatteryService: ObservableObject {
    static let shared = BatteryService()

    @Published var percentage: Int = 100
    @Published var isCharging: Bool = false
    @Published var isLowPowerMode: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled
    @Published var isAccurateHardwareRead: Bool = false
    @Published var chargingWatts: Int? = nil
    @Published var timeToFullMinutes: Int? = nil
    @Published var powerSourceType: String = "Battery"
    @Published var voltageVolts: Double? = nil
    @Published var amperageMilliAmps: Int? = nil
    @Published var cycleCount: Int? = nil
    @Published var batteryTempCelsius: Double? = nil

    private var hasWarnedOverheating: Bool = false
    private var hasNotifiedFullCharge: Bool = false

    private var timer: Timer?

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

        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NSProcessInfoPowerStateDidChange,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let isLow = ProcessInfo.processInfo.isLowPowerModeEnabled
            let wasLow = self.isLowPowerMode
            self.isLowPowerMode = isLow
            if isLow && !wasLow {
                IslandState.shared.triggerNotification(
                    title: "Low Power Mode On",
                    subtitle: "Battery Saver Active • \(self.percentage)%",
                    icon: "battery.100",
                    color: .yellow
                )
            } else if !isLow && wasLow {
                IslandState.shared.triggerNotification(
                    title: "Low Power Mode Off",
                    subtitle: "Full Performance Restored",
                    icon: "battery.100",
                    color: .green
                )
            }
        }

        // Fast 1.0s polling for continuous exact tracking
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateBattery()
        }
    }

    private func resolveIOKit() {
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

                    if let adapter = desc["AdapterDetails"] as? [String: Any],
                       let watts = adapter["Watts"] as? Int {
                        self.chargingWatts = watts
                    }

                    if let timeToFull = desc["Time to Full Charge"] as? Int, timeToFull > 0 && timeToFull < 1000 {
                        self.timeToFullMinutes = timeToFull
                    }

                    if let sourceState = desc["Power Source State"] as? String {
                        self.powerSourceType = sourceState
                    }

                    if let mv = desc["Voltage"] as? Int, mv > 0 {
                        self.voltageVolts = Double(mv) / 1000.0
                    }

                    if let ma = desc["Amperage"] as? Int {
                        self.amperageMilliAmps = ma
                    }

                    if let cycles = desc["Cycle Count"] as? Int, cycles > 0 {
                        self.cycleCount = cycles
                    }

                    if let tempRaw = desc["Temperature"] as? Int, tempRaw > 0 {
                        self.batteryTempCelsius = tempRaw > 1000 ? Double(tempRaw) / 100.0 : Double(tempRaw) / 10.0
                    }
                    evaluateBatteryAlerts()
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
        self.chargingWatts = nil
        self.timeToFullMinutes = nil
        evaluateBatteryAlerts()
    }

    private func evaluateBatteryAlerts() {
        if self.percentage == 100 && self.isCharging && !self.hasNotifiedFullCharge {
            self.hasNotifiedFullCharge = true
            IslandState.shared.triggerNotification(
                title: "Fully Charged",
                subtitle: "Battery 100% • Optimal Health",
                icon: "battery.100.bolt",
                color: .green
            )
        } else if !self.isCharging {
            self.hasNotifiedFullCharge = false
        }

        if let temp = self.batteryTempCelsius {
            if temp > 42.0 && !self.hasWarnedOverheating {
                self.hasWarnedOverheating = true
                IslandState.shared.triggerNotification(
                    title: "Device Hot (\(String(format: "%.1f°C", temp)))",
                    subtitle: "iPhone needs to cool down",
                    icon: "thermometer.sun.fill",
                    color: .red
                )
            } else if temp < 38.0 {
                self.hasWarnedOverheating = false
            }
        }
    }
}
