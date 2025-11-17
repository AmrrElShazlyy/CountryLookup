//
//  MockURLProtocol.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?
    static var requestFailed = false
    static var decodingFailed = false
    
    static func resetMockData() {
        requestHandler = nil
        requestFailed = false
        decodingFailed = false
    }
    
    static func populateRequestHandler() {
        requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 0, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        do {
            guard let handler = MockURLProtocol.requestHandler else {
                fatalError("Handler is unavailable.")
            }
            
            if MockURLProtocol.decodingFailed {
                throw NSError(domain: "com.example.errorDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Simulated generic error"])
            }
            
            let (response, data) = try handler(request)
            
            if MockURLProtocol.requestFailed {
                client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: .notAllowed)
            } else {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}
