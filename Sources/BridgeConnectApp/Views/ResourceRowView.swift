import SwiftUI
import BridgeConnectKit

struct ResourceRowView: View {
    let resource: Resource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(resource.name)
                    .font(.headline)
                Spacer()
                resourceTypeIcon
            }
            
            Text(resource.resourceDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !resource.hours.isEmpty {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text(resource.hours)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !resource.phone.isEmpty {
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.green)
                    Text(resource.phone)
                        .font(.caption)
                }
            }
            
            if !resource.address.isEmpty {
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.red)
                    Text(resource.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var resourceTypeIcon: some View {
        let iconName: String
        let color: Color
        
        switch ResourceType(rawValue: resource.type) ?? .other {
        case .shelter:
            iconName = "house"
            color = .purple
        case .foodBank:
            iconName = "fork.knife"
            color = .orange
        case .shower:
            iconName = "drop"
            color = .blue
        case .library:
            iconName = "books.vertical"
            color = .brown
        case .health:
            iconName = "cross.case"
            color = .red
        case .mentalHealth:
            iconName = "brain.head.profile"
            color = .pink
        case .jobCenter:
            iconName = "briefcase"
            color = .green
        case .other:
            iconName = "questionmark.circle"
            color = .gray
        }
        
        return Image(systemName: iconName)
            .foregroundColor(color)
    }
}
