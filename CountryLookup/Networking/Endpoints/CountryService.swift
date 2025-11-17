//
//  CountryService.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation
import Combine

protocol CountryService {
    func fetchCountries(name: String) -> AnyPublisher<[Country], APIError>
    func fetchCountyByCode(_ code: String) -> AnyPublisher<[Country], APIError>
}

class CountryServiceProvider: CountryService {
    private let apiClient = URLSessionAPIClient<CountryEndpoint>()
    
    func fetchCountries(name: String) -> AnyPublisher<[Country], APIError> {
        return apiClient.request(.country(name: name))
    }

    func fetchCountyByCode(_ code: String) -> AnyPublisher<[Country], APIError> {
        return apiClient.request(.countryCode(code: code))
    }
}
