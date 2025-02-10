import SwiftUI
import BridgeConnectKit

struct FilterView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ResourceViewModel
    
    // Local state to manage filter values
    @State private var selectedType: ResourceType?
    @State private var selectedRadius: Double
    
    private let radiusOptions: [(label: String, value: Double)] = [
        ("1 km", 1000),
        ("2 km", 2000),
        ("5 km", 5000),
        ("10 km", 10000),
        ("20 km", 20000)
    ]
    
    init(viewModel: ResourceViewModel) {
        self.viewModel = viewModel
        _selectedType = State(initialValue: viewModel.selectedType)
        _selectedRadius = State(initialValue: viewModel.selectedRadius)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Resource Type Section
                Section("Resource Type") {
                    Button {
                        selectedType = nil
                    } label: {
                        HStack {
                            Text("All Types")
                            Spacer()
                            if selectedType == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    ForEach(ResourceType.allCases, id: \.self) { type in
                        Button {
                            selectedType = type
                        } label: {
                            HStack {
                                Label(
                                    type.displayName,
                                    systemImage: type.iconName
                                )
                                Spacer()
                                if selectedType == type {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // Search Radius Section
                Section("Search Radius") {
                    ForEach(radiusOptions, id: \.value) { option in
                        Button {
                            selectedRadius = option.value
                        } label: {
                            HStack {
                                Text(option.label)
                                Spacer()
                                if selectedRadius == option.value {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                // Reset Button Section
                Section {
                    Button("Reset Filters") {
                        selectedType = nil
                        selectedRadius = 5000 // Default radius
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        Task {
                            await viewModel.applyFilters(
                                type: selectedType,
                                radius: selectedRadius
                            )
                            dismiss()
                        }
                    }
                    .bold()
                }
            }
        }
    }
}

// MARK: - Preview Provider

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(viewModel: ResourceViewModel())
    }
} 