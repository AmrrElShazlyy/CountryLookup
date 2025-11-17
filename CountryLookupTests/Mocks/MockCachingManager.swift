//
//  MockCachingManager.swift
//  CountryLookupTests
//
//  Created by Amr El Shazly on 16/11/2025.
//

import Foundation
@testable import CountryLookup

final class MockCachingManager: CachingManagerProtocol {
    var savedCountries: [Country] = []
    var saveCountryCallCount = 0
    var fetchCountriesCallCount = 0
    var deleteCountryCallCount = 0
    
    var shouldSimulateError = false
    
    func save(country: Country) {
        saveCountryCallCount += 1
        if !savedCountries.contains(where: { $0.name.common == country.name.common }) {
            savedCountries.append(country)
        }
    }
    
    func fetchCountries() -> [Country] {
        fetchCountriesCallCount += 1
        return savedCountries
    }
    
    func delete(country: Country) {
        deleteCountryCallCount += 1
        savedCountries.removeAll { $0.name.common == country.name.common }
    }
}
