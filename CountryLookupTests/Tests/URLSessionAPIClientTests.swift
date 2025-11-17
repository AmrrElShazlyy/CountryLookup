//
//  URLSessionAPIClientTests.swift
//  CountryLookupTests
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation
import XCTest
import Combine
@testable import CountryLookup

@MainActor
final class URLSessionAPIClientTests: XCTestCase {
    var apiClient: URLSessionAPIClient<CountryEndpoint>!
    
    override func setUp() {
        super.setUp()
        apiClient = URLSessionAPIClient<CountryEndpoint>(session: MockURLSession())
    }
    
    override func tearDown() {
        apiClient = nil
        super.tearDown()
    }
    
    func test_request_success() {
        // Given
        let expectedCountry = Country(
            name: CountryName(common: "Egypt", official: "Egypt"),
            currencies: ["EGP": CountryCurrency(name: "Egyptian pound", symbol: "£")],
            capital: ["Cairo"],
            flag: "flag"
        )
        let data = try! XCTUnwrap(JSONEncoder().encode([expectedCountry]))
        let expectation = XCTestExpectation(description: "Request done successfully!")
        MockURLProtocol.resetMockData()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        // When
        _ = apiClient.request(.country(name: "Egypt"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    XCTFail("Unexpected failure: \(error)")
                }
            }, receiveValue: { (response: [Country]) in
                // Then
                XCTAssertEqual(response.first?.name.common, expectedCountry.name.common)
                XCTAssertEqual(response.first?.capital.first, expectedCountry.capital.first)
                XCTAssertEqual(response.first?.currencies.first?.value.name, expectedCountry.currencies.first?.value.name)
                XCTAssertEqual(response.first?.flag, expectedCountry.flag)
                expectation.fulfill()

            })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_request_failure_customError() {
        // Given
        let expectation = XCTestExpectation(description: "Request failed!")
        MockURLProtocol.resetMockData()
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: URL(string: "http://example.com")!, statusCode: 402, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        // When
        _ = apiClient.request(.country(name: "Egypt"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Unexpected success")
                case let .failure(error):
                    // Then
                    XCTAssertEqual(error, APIError.customError(statusCode: 402))
                    expectation.fulfill()                }
            }, receiveValue: { (response: [Country]) in
                XCTFail("Unexpected response \(response)")
                expectation.fulfill()
                
            })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_request_failure_decodingFailed() {
        // Given
        let expectation = XCTestExpectation(description: "Request failed!")
        MockURLProtocol.resetMockData()
        MockURLProtocol.populateRequestHandler()
        MockURLProtocol.decodingFailed = true
        
        // When
        _ = apiClient.request(.country(name: "Egypt"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Unexpected success")
                case let .failure(error):
                    // Then
                    XCTAssertEqual(error, APIError.decodingFailed)
                    expectation.fulfill()
                }
            }, receiveValue: { (response: [Country]) in
                XCTFail("Unexpected response \(response)")
                expectation.fulfill()
                
            })
        
        wait(for: [expectation], timeout: 1)
    }
    
    func test_request_failure_requestFailed() {
        // Given
        let expectation = XCTestExpectation(description: "Request failed!")
        MockURLProtocol.resetMockData()
        MockURLProtocol.populateRequestHandler()
        MockURLProtocol.requestFailed = true
        
        // When
        _ = apiClient.request(.country(name: "Egypt"))
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    XCTFail("Unexpected success")
                case let .failure(error):
                    // Then
                    XCTAssertEqual(error, APIError.requestFailed)
                    expectation.fulfill()
                }
            }, receiveValue: { (response: [Country]) in
                XCTFail("Unexpected response \(response)")
                expectation.fulfill()
                
            })
        
        wait(for: [expectation], timeout: 1)
    }
    
}
