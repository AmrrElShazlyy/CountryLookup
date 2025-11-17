//
//  MockLocationService.swift
//  CountryLookupTests
//
//  Created by Amr El Shazly on 15/11/2025.
//

import Foundation
@testable import CountryLookup

final class MockLocationService: LocationServiceProtocol {
    var requestLocationCallCount = 0
    
    func requestLocationAndGetCountryCode() async -> String? {
        requestLocationCallCount += 1
        return "eg"
    }
}
