import SwiftUI
import BridgeConnectKit

@main
struct BridgeConnectApp: App {
    init() {
        // Initialize BridgeConnectKit
        try? BridgeConnectKit.initialize()
        
        // Add sample data if needed
        #if DEBUG
        if BridgeConnectKit.shared.resourceRepository.getAllResources().isEmpty {
            let sampleResource = Resource(
                name: "Community Center",
                resourceDescription: "Local community center with various programs",
                type: "Community",
                latitude: 37.7749,
                longitude: -122.4194,
                address: "123 Main St, San Francisco, CA",
                phone: "(415) 555-0123",
                email: "info@communitycenter.org",
                website: "www.communitycenter.org"
            )
            try? BridgeConnectKit.shared.resourceRepository.save(sampleResource)
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            ResourceListView()
                .tabItem {
                    Label("Resources", systemImage: "list.bullet")
                }
            
            ResourceMapView()
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
} 