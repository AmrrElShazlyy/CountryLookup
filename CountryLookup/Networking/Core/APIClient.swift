//
//  APIClient.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation
import Combine

public protocol APIClient {
    associatedtype EndpointType: APIEndpoint
    func request<T: Codable>(_ endpoint: EndpointType) -> AnyPublisher<T, APIError>
}

protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

extension URLSession: URLSessionProtocol { }

class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    private var session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func request<T: Codable>(_ endpoint: EndpointType) -> AnyPublisher<T, APIError> {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        endpoint.headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        return session.dataTaskPublisher(for: request)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.requestFailed
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw APIError.customError(statusCode: httpResponse.statusCode)
                }
                
                return data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                guard let error = error as? APIError else {
                    return APIError.decodingFailed
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}
