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
            type: .dynamic,
            targets: ["BridgeConnectKit"]
        ),
        .library(
            name: "BridgeConnectApp",
            type: .dynamic,
            targets: ["BridgeConnectApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", exact: "5.10.2"),
        .package(url: "https://github.com/realm/realm-swift.git", exact: "10.54.2")
    ],
    targets: [
        // Framework target
        .target(
            name: "BridgeConnectKit",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
                .product(name: "RealmSwift", package: "realm-swift")
            ],
            path: "Sources/BridgeConnectKit",
            resources: [
                .process("Resources")
            ]
        ),
        // App target
        .target(
            name: "BridgeConnectApp",
            dependencies: [
                "BridgeConnectKit",
                .product(name: "RealmSwift", package: "realm-swift"),
                .product(name: "Alamofire", package: "Alamofire")
            ],
            path: "Sources/BridgeConnectApp"
        ),
        // Test targets
        .testTarget(
            name: "BridgeConnectKitTests",
            dependencies: ["BridgeConnectKit"]
        ),
        .testTarget(
            name: "BridgeConnectAppTests",
            dependencies: ["BridgeConnectApp"]
        )
    ]
) 