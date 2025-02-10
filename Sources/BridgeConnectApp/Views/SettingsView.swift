import SwiftUI
import BridgeConnectKit

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("searchRadius") private var searchRadius: Double = 5000
    @AppStorage("showNotifications") private var showNotifications = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Search")) {
                    VStack(alignment: .leading) {
                        Text("Search Radius: \(Int(searchRadius))m")
                        Slider(value: $searchRadius, in: 1000...10000, step: 1000)
                    }
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $showNotifications)
                }
                
                Section(header: Text("Data Management")) {
                    Button("Clear Local Data") {
                        viewModel.showClearDataAlert = true
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(viewModel.appVersion)
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                }
            }
            .navigationTitle("Settings")
            .alert("Clear Data", isPresented: $viewModel.showClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    viewModel.clearLocalData()
                }
            } message: {
                Text("This will delete all locally stored data. This action cannot be undone.")
            }
        }
    }
}

class SettingsViewModel: ObservableObject {
    @Published var showClearDataAlert = false
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    func clearLocalData() {
        do {
            try BridgeConnectKit.shared.resourceRepository.deleteAll()
        } catch {
            print("Error clearing data: \(error)")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
} 