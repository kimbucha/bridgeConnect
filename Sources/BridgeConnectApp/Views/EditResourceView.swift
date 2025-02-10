import SwiftUI
import MapKit
import BridgeConnectKit

struct EditResourceView: View {
    @Environment(\.presentationMode) var presentationMode
    let resource: Resource
    @StateObject private var viewModel: EditResourceViewModel
    
    init(resource: Resource) {
        self.resource = resource
        _viewModel = StateObject(wrappedValue: EditResourceViewModel(resource: resource))
    }
    
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
            .navigationTitle("Edit Resource")
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

class EditResourceViewModel: ObservableObject {
    @Published var name: String
    @Published var resourceDescription: String
    @Published var type: String
    @Published var address: String
    @Published var phone: String
    @Published var email: String
    @Published var website: String
    
    @Published var region: MKCoordinateRegion
    @Published var annotations: [LocationAnnotation]
    @Published var isLoadingLocation = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let resource: Resource
    private let geocoder = CLGeocoder()
    private let repository = BridgeConnectKit.shared.resourceRepository
    
    init(resource: Resource) {
        self.resource = resource
        self.name = resource.name
        self.resourceDescription = resource.resourceDescription
        self.type = resource.type
        self.address = resource.address
        self.phone = resource.phone
        self.email = resource.email
        self.website = resource.website
        
        let coordinate = CLLocationCoordinate2D(
            latitude: resource.latitude,
            longitude: resource.longitude
        )
        
        self.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        self.annotations = [LocationAnnotation(coordinate: coordinate)]
    }
    
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
        
        do {
            try repository?.update(resource) { resource in
                resource.name = name
                resource.resourceDescription = resourceDescription
                resource.type = type
                resource.latitude = coordinate.latitude
                resource.longitude = coordinate.longitude
                resource.address = address
                resource.phone = phone
                resource.email = email
                resource.website = website
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
        }
    }
}
