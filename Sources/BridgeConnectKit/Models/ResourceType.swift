import Foundation

import Foundation

public enum ResourceType: String, CaseIterable {
    case shelter = "shelter"
    case foodBank = "food_bank"
    case shower = "shower"
    case library = "library"
    case health = "health"
    case mentalHealth = "mental_health"
    case jobCenter = "job_center"
    case other = "other"
    
    public var displayName: String {
        switch self {
        case .shelter:
            return "Emergency Shelter"
        case .foodBank:
            return "Food Bank"
        case .shower:
            return "Public Shower"
        case .library:
            return "Public Library"
        case .health:
            return "Health Services"
        case .mentalHealth:
            return "Mental Health Services"
        case .jobCenter:
            return "Job Center"
        case .other:
            return "Other"
        }
    }
    
    public var googlePlacesTypes: [String] {
        switch self {
        case .shelter:
            return ["lodging", "local_government_office"]
        case .foodBank:
            return ["food_bank", "meal_takeaway", "food"]
        case .shower:
            return ["gym", "local_government_office"]
        case .library:
            return ["library", "book_store"]
        case .health:
            return ["hospital", "doctor", "pharmacy"]
        case .mentalHealth:
            return ["doctor", "health"]
        case .jobCenter:
            return ["local_government_office", "employment_agency"]
        case .other:
            return ["point_of_interest"]
        }
    }
    
    public static func fromGooglePlacesType(_ type: String) -> ResourceType {
        let lowercasedType = type.lowercased()
        for resourceType in ResourceType.allCases {
            if resourceType.googlePlacesTypes.contains(lowercasedType) {
                return resourceType
            }
        }
        return .other
    }
    
    public static func from(string: String) -> ResourceType {
        return ResourceType(rawValue: string.lowercased()) ?? .other
    }
    
    public static var allDisplayNames: [String] {
        return allCases.map { $0.displayName }
    }
    
    public static var allRawValues: [String] {
        return allCases.map { $0.rawValue }
    }
}
