import SwiftUI

/// Represents a category of emergency resources
public struct ResourceCategory: Identifiable, Equatable, CaseIterable {
    public static var allCases: [ResourceCategory] { categories }
    public static func == (lhs: ResourceCategory, rhs: ResourceCategory) -> Bool {
        lhs.id == rhs.id
    }
    
    public let id = UUID()
    public let title: String
    public let icon: String
    public let color: Color
    public let types: [String]
    
    public init(title: String, icon: String, color: Color, types: [String]) {
        self.title = title
        self.icon = icon
        self.color = color
        self.types = types
    }
    
    /// Predefined categories of emergency resources
    public static let categories: [ResourceCategory] = [
        ResourceCategory(
            title: "Emergency Shelter",
            icon: "house.fill",
            color: .purple,
            types: ["shelter"]
        ),
        ResourceCategory(
            title: "Food & Meals",
            icon: "fork.knife",
            color: .orange,
            types: ["food_bank"]
        ),
        ResourceCategory(
            title: "Health Services",
            icon: "cross.case.fill",
            color: .red,
            types: ["health", "mental_health"]
        ),
        ResourceCategory(
            title: "Hygiene",
            icon: "drop.fill",
            color: .blue,
            types: ["shower"]
        ),
        ResourceCategory(
            title: "Community Resources",
            icon: "building.2.fill",
            color: .brown,
            types: ["library", "job_center"]
        )
    ]
}
