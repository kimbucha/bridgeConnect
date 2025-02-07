// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "BridgeConnect",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "BridgeConnectKit",
            targets: ["BridgeConnectKit"]
        ),
        .executable(
            name: "BridgeConnect",
            targets: ["BridgeConnectApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/realm/realm-swift.git", from: "10.45.2")
    ],
    targets: [
        // Framework target
        .target(
            name: "BridgeConnectKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources/BridgeConnectKit"
        ),
        // App target
        .target(
            name: "BridgeConnectApp",
            dependencies: [
                "BridgeConnectKit"
            ],
            path: "Sources/BridgeConnectApp"
        ),
        // Test targets
        .testTarget(
            name: "BridgeConnectKitTests",
            dependencies: ["BridgeConnectKit"],
            path: "Tests/BridgeConnectKitTests"
        ),
        .testTarget(
            name: "BridgeConnectAppTests",
            dependencies: ["BridgeConnectApp"],
            path: "Tests/BridgeConnectAppTests"
        )
    ]
) 