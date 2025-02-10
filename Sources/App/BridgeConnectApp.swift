import SwiftUI
import BridgeConnectKit

@main
struct BridgeConnectApp: App {
    init() {
        // Initialize the Core module
        Core.initialize()
        
        // Configure global appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationView {
                    ResourceListView(viewModel: ResourceViewModel())
                }
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
                
                NavigationView {
                    ResourceMapView(viewModel: ResourceViewModel())
                }
                .tabItem {
                    Label("Map", systemImage: "map")
                }
            }
        }
    }
    
    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
} 