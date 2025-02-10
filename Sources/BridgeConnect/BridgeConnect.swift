// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import RealmSwift
import CoreLocation

public enum BridgeConnect {
    public static let version = "1.0.0"
    
    public static func initialize() {
        Core.initialize()
    }
    
    public static func resetCache() {
        Core.resetCache()
    }
}
