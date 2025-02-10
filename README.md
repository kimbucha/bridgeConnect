# BridgeConnect

BridgeConnect is a comprehensive iOS application and Swift framework for managing and connecting community resources.

## Features

### iOS App
- Tab-based interface with list and map views
- Location-based resource discovery
- Advanced filtering by resource type and radius
- Detailed resource information with contact options
- Interactive map with custom annotations
- Pull-to-refresh functionality
- Error handling and offline support
- Adaptive layout for iPhone and iPad

### Framework
- Resource management with Realm persistence
- Network communication using Alamofire
- Comprehensive logging system using OSLog
- Type-safe API endpoints
- Location-based resource discovery
- Efficient caching system

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.5+

## Project Structure

```
BridgeConnect/
├── Sources/
│   ├── App/
│   │   ├── Views/
│   │   │   ├── Resource/
│   │   │   │   ├── ResourceListView.swift
│   │   │   │   ├── ResourceMapView.swift
│   │   │   │   ├── ResourceDetailView.swift
│   │   │   │   └── FilterView.swift
│   │   │   └── Components/
│   │   ├── ViewModels/
│   │   │   └── ResourceViewModel.swift
│   │   └── BridgeConnectApp.swift
│   └── BridgeConnect/
│       ├── Core/
│       ├── Models/
│       ├── Protocols/
│       ├── Services/
│       └── Repositories/
```

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/BridgeConnect.git", from: "1.0.0")
]
```

## Usage

### Framework Initialization

```swift
import BridgeConnect

// Initialize the Core module
Core.initialize()
```

### Working with Resources

```swift
// Get resource suggestions
let suggestions = try await Core.shared.resourceRepository.getSuggestions(
    query: "food bank",
    location: Location(latitude: 37.7749, longitude: -122.4194),
    radius: 5000
)

// Save a resource
let resource = Resource(
    name: "Local Food Bank",
    description: "Provides food assistance to the community",
    type: .foodBank,
    latitude: 37.7749,
    longitude: -122.4194
)
try await Core.shared.resourceRepository.save(resource)
```

## Architecture

BridgeConnect follows a clean architecture pattern with the following components:

### iOS App
- **Views**: SwiftUI views implementing the user interface
- **ViewModels**: Managing view state and business logic
- **Models**: Shared data models with the framework

### Framework
- **Core**: Central module managing all services and repositories
- **Models**: Data models representing resources and related entities
- **Protocols**: Interfaces defining service contracts
- **Services**: Implementations of network and logging services
- **Repositories**: Data access layer managing persistence

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details. 