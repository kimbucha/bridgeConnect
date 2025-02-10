import Foundation
import CoreLocation

// MARK: - Repository Protocol
public protocol ResourceRepository {
    func getAll() async throws -> [Resource]
    func get(id: String) async throws -> Resource?
    func search(query: String?, location: Location, radius: Double) async throws -> [Resource]
    func searchResources(query: String?, location: Location, type: ResourceType?, radius: Double) async throws -> [Resource]
    func save(_ resource: Resource) async throws
    func delete(_ resource: Resource) async throws
    func saveAll(_ resources: [Resource]) async throws
    func update(_ resource: Resource) async throws
    func deleteAll(_ resources: [Resource]) async throws
    func exists(id: String) async throws -> Bool
    func count() async throws -> Int
    func getSuggestions(query: String, location: Location, radius: Double) async throws -> [Resource]
}

// MARK: - Logger Protocol
public protocol LoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

public extension LoggerProtocol {
    func log(_ message: String,
            level: LogLevel = .info,
            file: String = #file,
            function: String = #function,
            line: Int = #line) {
        log(message, level: level, file: file, function: function, line: line)
    }
}

// MARK: - Network Protocol
public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: String,
                              method: HTTPMethod,
                              parameters: [String: Any]?,
                              headers: [String: String]?) async throws -> T
    
    func search(_ parameters: SearchParameters) async throws -> [Resource]
    func getNearbyResources(location: Location, radius: Double) async throws -> [Resource]
    
    func upload(_ data: Data,
                to endpoint: String,
                method: HTTPMethod,
                parameters: [String: Any]?,
                headers: [String: String]?) async throws -> String
    
    func download(_ url: URL) async throws -> Data
}

// MARK: - Enums
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    case critical = "CRITICAL"
    
    public var emoji: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

// MARK: - Errors
public enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case unauthorized
    case notFound
    case serverError
    case encodingFailed
    
    public var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .notFound:
            return "Resource not found"
        case .serverError:
            return "Server error occurred"
        case .encodingFailed:
            return "Failed to encode request parameters"
        }
    }
}

public enum ResourceError: Error {
    case networkError(Error)
    case invalidResponse
    case resourceNotFound
    case cacheError(Error)
    case invalidData
    
    public var localizedDescription: String {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .resourceNotFound:
            return "Resource not found"
        case .cacheError(let error):
            return "Cache error: \(error.localizedDescription)"
        case .invalidData:
            return "Invalid data format"
        }
    }
} 