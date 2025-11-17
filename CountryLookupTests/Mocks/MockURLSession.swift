//
//  MockURLSession.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Combine
import Foundation
@testable import CountryLookup

class MockURLSession: URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        return URLSession.DataTaskPublisher(request: request, session: session)
    }
}
