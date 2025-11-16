//
//  CountrySearchViewModelTests.swift
//  CountryLookupTests
//
//  Created by Amr El Shazly on 15/11/2025.
//

import Foundation
import XCTest
import Combine
@testable import CountryLookup

@MainActor
final class CountrySearchViewModelTests: XCTestCase {
    
    var viewModel: CountrySearchViewModel!
    var mockCountryService: MockCountryServiceProvider!
    var mockLocationService: MockLocationService!
    var mockAPIClient: MockAPIClient<CountryEndpoint>!
    var mockCachingManager: MockCachingManager!
    var cancellables: Set<AnyCancellable>! = []
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient<CountryEndpoint>()
        mockCountryService = MockCountryServiceProvider(apiClient: mockAPIClient)
        mockLocationService = MockLocationService()
        mockCachingManager = MockCachingManager()
        viewModel = CountrySearchViewModel(
            countryService: mockCountryService,
            locationService: mockLocationService,
            cachingManager: mockCachingManager
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockCountryService = nil
        mockLocationService = nil
        mockAPIClient = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Search Tests
    func test_searchText_withValidCountry_success() {
        // Given
        let expectedCountry = createMockCountry(name: "Egypt")
        mockAPIClient.requestResult = .success( try! JSONEncoder().encode([expectedCountry]))
        let expectation = XCTestExpectation(description: "Search completes")
        
        // When
        viewModel.searchText = "Egypt"
        
        // Then
        viewModel.$searchState
            .dropFirst()
            .sink { state in
                if case .success(let countries) = state {
                    XCTAssertEqual(countries.count, 1)
                    XCTAssertEqual(countries.first?.name.common, "Egypt")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_searchText_withRequestFailed_setsNetworkErrorMessage() {
        // Given
        mockAPIClient.requestResult = .failure(.requestFailed)
        let expectation = XCTestExpectation(description: "Search fails")
        
        // When
        viewModel.searchText = "Egypt"
        
        // Then
        viewModel.$searchState
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, "Network request failed. Please try again.")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_searchText_withInvalidCountryName_setError404() {
        // Given
        mockAPIClient.requestResult = .failure(.customError(statusCode: 404))
        let expectation = XCTestExpectation(description: "Search fails with 404")
        
        // When
        viewModel.searchText = "aassddffgg"
        
        // Then
        viewModel.$searchState
            .dropFirst()
            .sink { state in
                if case .error(let message) = state {
                    XCTAssertEqual(message, "No countries found.")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 2)
    }
    
    func test_tryToSearchText_MaxLimitReached_showsAlert() {
        // Given
        for i in 1...5 {
            let country = createMockCountry(name: "country\(i)")
            viewModel.addCountry(country)
        }
        XCTAssertEqual(viewModel.addedCountries.count, 5)
        
        // When
        viewModel.searchText = "nn"
        
        // Then
        let expectation = XCTestExpectation(description: "alert shows")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.showAlert)
            XCTAssertEqual(self.viewModel.alertTitle, "Maximum Limit Reached")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    // MARK: - Add Country Tests
    func test_addCountry_addsCountryToList() {
        // Given
        let country = createMockCountry(name: "Egypt")
        
        // When
        viewModel.addCountry(country)
        
        // Then
        XCTAssertEqual(viewModel.addedCountries.count, 1)
        XCTAssertEqual(viewModel.addedCountries.first?.name.common, "Egypt")
    }
    
    func test_addCountry_clearsSearchText() {
        // Given
        let country = createMockCountry(name: "Egypt")
        viewModel.searchText = "Egypt"
        
        // When
        viewModel.addCountry(country)
        
        // Then
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(mockCachingManager.saveCountryCallCount, 1)
        XCTAssertEqual(mockCachingManager.savedCountries.count, 1)
        XCTAssertEqual(mockCachingManager.savedCountries.first?.name.common, "Egypt")
    }
    
    func test_addCountryAlreadyAdded_doesNotAdd() {
        // Given
        let country = createMockCountry(name: "Egypt")
        viewModel.addCountry(country)
        
        // When
        viewModel.addCountry(country)
        
        // Then
        XCTAssertEqual(viewModel.addedCountries.count, 1)
    }
    
    // MARK: - Remove Country Tests
    func test_removeCountry_removesCountryFromList() {
        // Given
        let country = createMockCountry(name: "Egypt")
        viewModel.addCountry(country)
        XCTAssertEqual(viewModel.addedCountries.count, 1)
        
        // When
        viewModel.removeCountry(at: IndexSet(integer: 0))
        
        // Then
        XCTAssertEqual(viewModel.addedCountries.count, 0)
        XCTAssertEqual(mockCachingManager.deleteCountryCallCount, 1)
        XCTAssertEqual(mockCachingManager.savedCountries.count, 0)
    }

    // MARK: - Auto-Add Location Tests
    func test_autoAddCountryBasedOnLocation() async {
        // Given
        let country = createMockCountry(name: "egypt")
        mockAPIClient.requestResult = .success(try! JSONEncoder().encode([country]))
        viewModel.isLaunchedBefore = false

        // When
        await viewModel.autoAddCountryBasedOnLocation()
        
        // Then
        XCTAssertEqual(mockLocationService.requestLocationCallCount, 1)
        let expectation = XCTestExpectation(description: "Country added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.viewModel.addedCountries.count, 1)
            XCTAssertEqual(self.viewModel.addedCountries.first?.name.common, "egypt")
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func test_autoAddCountryBasedOnLocation_calledTwice_setIsLaunchedBefore() async {
        // Given
        let country = createMockCountry(name: "egypt")
        mockAPIClient.requestResult = .success(try! JSONEncoder().encode([country]))
        
        // When
        await viewModel.autoAddCountryBasedOnLocation()
        await viewModel.autoAddCountryBasedOnLocation()
        
        // Then
        let expectation = XCTestExpectation(description: "Country added")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertTrue(self.viewModel.isLaunchedBefore)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_loadCachedCountries_success() {
        // Given
        let country1 = createMockCountry(name: "country1")
        let country2 = createMockCountry(name: "country2")
        mockCachingManager.savedCountries = [country1, country2]
        
        // When
        viewModel.loadCachedCountries()
        
        // Then
        XCTAssertEqual(mockCachingManager.fetchCountriesCallCount, 1)
        XCTAssertEqual(mockCachingManager.savedCountries.count, 2)
        XCTAssertEqual(viewModel.addedCountries.count, 2)
        XCTAssertEqual(viewModel.addedCountries.first?.name.common, "country1")
    }
    
    func test_loadCachedCountries_calledMultipleTimes_onlyLoadsOnce() {
        // Given
        let country1 = createMockCountry(name: "country1")
        let country2 = createMockCountry(name: "country2")
        mockCachingManager.savedCountries = [country1, country2]
        
        // When
        viewModel.loadCachedCountries()
        viewModel.loadCachedCountries()
        viewModel.loadCachedCountries()
        
        // Then
        XCTAssertEqual(mockCachingManager.fetchCountriesCallCount, 1)
        XCTAssertEqual(mockCachingManager.savedCountries.count, 2)
    }

    // MARK: - Helper Methods
    private func createMockCountry(name: String) -> Country {
        return Country(
            name: CountryName(common: name, official: (name)),
            currencies: ["$" : CountryCurrency(name: "$", symbol: "$")],
            capital: ["cairo"],
            flag: "flag",
        )
    }
}
