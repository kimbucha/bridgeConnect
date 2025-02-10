import SwiftUI

extension PreviewProvider {
    static var previewDevices: some View {
        Group {
            NavigationView {
                self.previews
            }
            .previewDisplayName("iPhone 14 Pro")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            
            NavigationView {
                self.previews
            }
            .previewDisplayName("iPhone SE")
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            
            NavigationView {
                self.previews
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            
            if #available(iOS 15.0, *) {
                NavigationView {
                    self.previews
                }
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDisplayName("Landscape")
                .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
            }
        }
    }
    
    static var previewStates: some View {
        Group {
            NavigationView {
                self.previews
            }
            .previewDisplayName("Default")
            
            NavigationView {
                self.previews
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
            
            NavigationView {
                self.previews
            }
            .environment(\.sizeCategory, .accessibilityLarge)
            .previewDisplayName("Large Text")
            
            if #available(iOS 15.0, *) {
                NavigationView {
                    self.previews
                }
                .environment(\.layoutDirection, .rightToLeft)
                .previewDisplayName("Right to Left")
            }
        }
    }
}
