import SwiftUI
import MapKit
import BridgeConnectKit

/// A SwiftUI wrapper for MapKit's MKMapView
struct MapView: UIViewRepresentable {
    /// The region to display
    @Binding var region: MKCoordinateRegion
    /// The annotations to display on the map
    let annotations: [ResourceAnnotation]
    /// Callback when an annotation is selected
    let onAnnotationSelected: (ResourceAnnotation) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.setRegion(region, animated: true)
        
        // Remove old annotations
        let oldAnnotations = view.annotations.filter { !($0 is MKUserLocation) }
        view.removeAnnotations(oldAnnotations)
        
        // Add new annotations
        view.addAnnotations(annotations)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? ResourceAnnotation else { return nil }
            
            let identifier = "ResourceAnnotation"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ??
                      MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            if let markerView = view as? MKMarkerAnnotationView {
                markerView.glyphImage = UIImage(systemName: annotation.resource.category?.icon ?? "mappin")
                if let categoryColor = annotation.resource.category?.color {
                    markerView.markerTintColor = UIColor(categoryColor)
                }
            }
            
            return view
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? ResourceAnnotation else { return }
            parent.onAnnotationSelected(annotation)
        }
    }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(
            region: .constant(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )),
            annotations: [
                ResourceAnnotation(resource: Resource(
                    name: "Sample Shelter",
                    description: "A sample emergency shelter",
                    address: "123 Main St",
                    phone: "555-1234",
                    website: "https://example.com",
                    hours: "24/7",
                    category: ResourceCategory.categories.first,
                    coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
                ))
            ],
            onAnnotationSelected: { _ in }
        )
    }
}
