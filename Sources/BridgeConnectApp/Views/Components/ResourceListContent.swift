import SwiftUI
import BridgeConnectKit

struct ResourceListContent: View {
    let resources: [Resource]
    let isLoading: Bool
    
    var body: some View {
        List {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
            
            ForEach(resources) { resource in
                NavigationLink(destination: ResourceDetailView(resource: resource)) {
                    ResourceRowView(resource: resource)
                }
            }
        }
        .listStyle(.plain)
    }
}
