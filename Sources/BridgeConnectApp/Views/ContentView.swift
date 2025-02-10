import SwiftUI
import BridgeConnectKit

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

#Preview {
    ContentView()
}
