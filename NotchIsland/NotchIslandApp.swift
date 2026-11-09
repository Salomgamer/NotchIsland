import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }

    func applicationDidFinishLaunching(_ application: UIApplication) {
        _ = BackgroundEngine.shared
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        BackgroundEngine.shared.ensureKeepAlive()
        let pip = PiPIslandManager.shared
        if pip.persistentKeepAlive && !pip.userExplicitlyDismissed && !pip.isPiPActive {
            pip.start()
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        BackgroundEngine.shared.ensureKeepAlive()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        BackgroundEngine.shared.ensureKeepAlive()
    }
}

@main
struct DynamicNotchApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
