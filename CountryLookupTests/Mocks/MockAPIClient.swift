//
//  MockAPIClient.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//


import Foundation
import Combine
@testable import CountryLookup

class MockAPIClient<EndpointType: APIEndpoint>: APIClient {
    var requestResult: Result<Data, APIError> = .failure(.requestFailed)
    
    func request<T: Codable>(_ endpoint: EndpointType) -> AnyPublisher<T, APIError> {
        return Result.Publisher(requestResult)
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                guard let apiError = error as? APIError else {
                    return APIError.decodingFailed
                }
                return apiError
            }
            .eraseToAnyPublisher()
    }
}
