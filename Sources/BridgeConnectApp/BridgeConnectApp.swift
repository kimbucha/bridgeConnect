import SwiftUI
import BridgeConnectKit

@main
struct BridgeConnectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Initialize BridgeConnectKit
        do {
            try BridgeConnectKit.shared.initialize()
        } catch {
            print("Failed to initialize BridgeConnectKit: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
} 