import Foundation
import Alamofire

public class NetworkService: NetworkServiceProtocol {
    private let session: Session
    private let baseURL: URL
    
    public init(baseURL: URL = URL(string: "https://api.bridgeconnect.com")!,
                session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: String,
                                     method: HTTPMethod = .get,
                                     parameters: [String: Any]? = nil,
                                     headers: [String: String]? = nil) async throws -> T {
        let request = session.request(
            baseURL.appendingPathComponent(endpoint),
            method: Alamofire.HTTPMethod(rawValue: method.rawValue),
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers.map { HTTPHeaders($0) }
        )
        
        let response = await request.serializingDecodable(T.self).response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func search(_ parameters: SearchParameters) async throws -> [Resource] {
        try await request("/resources/search",
                         method: .get,
                         parameters: try parameters.asDictionary())
    }
    
    public func getNearbyResources(location: Location, radius: Double) async throws -> [Resource] {
        try await request("/resources/nearby",
                         method: .get,
                         parameters: [
                            "latitude": location.latitude,
                            "longitude": location.longitude,
                            "radius": radius
                         ])
    }
    
    public func upload(_ data: Data,
                      to endpoint: String,
                      method: HTTPMethod = .post,
                      parameters: [String: Any]? = nil,
                      headers: [String: String]? = nil) async throws -> String {
        let request = session.upload(
            data,
            to: baseURL.appendingPathComponent(endpoint),
            method: Alamofire.HTTPMethod(rawValue: method.rawValue),
            headers: headers.map { HTTPHeaders($0) }
        )
        
        let response = await request.serializingString().response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw NetworkError.requestFailed(error)
        }
    }
    
    public func download(_ url: URL) async throws -> Data {
        let request = session.download(url)
        let response = await request.serializingData().response
        
        switch response.result {
        case .success(let value):
            return value
        case .failure(let error):
            throw NetworkError.requestFailed(error)
        }
    }
}

private extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NetworkError.encodingFailed
        }
        return dictionary
    }
} 