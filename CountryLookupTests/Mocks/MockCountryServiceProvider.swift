//
//  MockCountryServiceProvider.swift
//  CountryLookupTests
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation
import Combine
@testable import CountryLookup

@MainActor
class MockCountryServiceProvider: CountryService {
    var apiClient: MockAPIClient<CountryEndpoint>
    
    init(apiClient: MockAPIClient<CountryEndpoint>) {
        self.apiClient = apiClient
    }
    
    func fetchCountries(name: String) -> AnyPublisher<[Country], CountryLookup.APIError> {
        return apiClient.request(.country(name: name))
    }
    
    func fetchCountyByCode(_ code: String) -> AnyPublisher<[Country], CountryLookup.APIError> {
        return apiClient.request(.countryCode(code: code))
    }
}
