import SwiftUI
import MapKit
import BridgeConnectKit

struct AddResourceView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddResourceViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Name", text: $viewModel.name)
                    TextEditor(text: $viewModel.resourceDescription)
                        .frame(minHeight: 100)
                    Picker("Type", selection: $viewModel.type) {
                        ForEach(ResourceType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                }
                
                Section(header: Text("Location")) {
                    HStack {
                        TextField("Address", text: $viewModel.address)
                        if viewModel.isLoadingLocation {
                            ProgressView()
                        } else {
                            Button(action: viewModel.geocodeAddress) {
                                Image(systemName: "location.magnifyingglass")
                            }
                        }
                    }
                    
                    Map(coordinateRegion: $viewModel.region, annotationItems: viewModel.annotations) { annotation in
                        MapMarker(coordinate: annotation.coordinate)
                    }
                    .frame(height: 200)
                    .cornerRadius(8)
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Phone", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Website", text: $viewModel.website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Add Resource")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    viewModel.save()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(!viewModel.isValid)
            )
            .alert("Error", isPresented: $viewModel.showError, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(viewModel.errorMessage)
            })
        }
    }
}

class AddResourceViewModel: ObservableObject {
    @Published var name = ""
    @Published var resourceDescription = ""
    @Published var type = ResourceType.other.rawValue
    @Published var address = ""
    @Published var phone = ""
    @Published var email = ""
    @Published var website = ""
    
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @Published var annotations: [LocationAnnotation] = []
    @Published var isLoadingLocation = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let geocoder = CLGeocoder()
    private let repository = BridgeConnectKit.shared.resourceRepository
    
    var isValid: Bool {
        !name.isEmpty && !resourceDescription.isEmpty && !annotations.isEmpty
    }
    
    func geocodeAddress() {
        guard !address.isEmpty else { return }
        
        isLoadingLocation = true
        geocoder.geocodeAddressString(address) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                
                if let error = error {
                    self?.showError = true
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    self?.showError = true
                    self?.errorMessage = "Location not found"
                    return
                }
                
                self?.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
                
                self?.annotations = [LocationAnnotation(coordinate: location.coordinate)]
            }
        }
    }
    
    func save() {
        guard let coordinate = annotations.first?.coordinate else { return }
        
        let resource = Resource(
            name: name,
            resourceDescription: resourceDescription,
            type: ResourceType(rawValue: type) ?? .other,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            address: address,
            phone: phone,
            email: email,
            website: website
        )
        
        do {
            try repository?.save(resource)
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}
