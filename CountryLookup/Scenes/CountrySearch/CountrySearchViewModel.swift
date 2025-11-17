//
//  CountrySearchViewModel.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 14/11/2025.
//

import Foundation
import Combine
import Network
import SwiftUI
import SwiftData

enum SearchState {
    case idle
    case searching
    case success(countries: [Country])
    case error(message: String)
}

@MainActor
class CountrySearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var searchState: SearchState = .idle
    @Published var addedCountries: [Country] = []
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    @AppStorage("isLaunchedBefore") var isLaunchedBefore = false

    // MARK: - Private Properties
    private let maxCountriesLimit = 5
    private let countryService: CountryService
    private let cachingManager: CachingManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    private let networkMonitor = NWPathMonitor()
    private let networkMonitorQueue = DispatchQueue(label: "NetworkMontorQueue")
    private var isNetworkAvailable: Bool = true
    private let locationService: LocationServiceProtocol
    private let defaultCountryCode = "EG"
    private var isCountriesLoadedFromCache = false

    init(
        countryService: CountryService,
        locationService: LocationServiceProtocol,
        cachingManager: CachingManagerProtocol
    ) {
        self.countryService = countryService
        self.locationService = locationService
        self.cachingManager = cachingManager
        setupNetworkMonitor()
        setupSearchTextObservers()
    }
    
    convenience init(modelContainer: ModelContainer) {
        self.init(
            countryService: CountryServiceProvider(),
            locationService: LocationManager(),
            cachingManager: CachingManager(modelContainer: modelContainer)
        )
    }
    
    deinit {
        networkMonitor.cancel()
    }
    
    private func setupNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isNetworkAvailable = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: networkMonitorQueue)
    }
    
    private func setupSearchTextObservers() {
        $searchText
            .sink { [weak self] searchText in
                guard let self = self else { return }
                if !searchText.isEmpty && addedCountries.count >= maxCountriesLimit {
                    showMaxLimitAlert()
                    return
                }
            }
            .store(in: &cancellables)
        
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                guard let self = self else { return }

                if searchText.isEmpty {
                    searchState = .idle
                } else {
                    guard addedCountries.count < maxCountriesLimit else {
                        return
                    }
                    searchCountries(query: searchText)
                }
            }
            .store(in: &cancellables)

    }
    
    private func searchCountries(query: String) {
        guard !query.isEmpty else {
            searchState = .idle
            return
        }
        
        guard isNetworkAvailable else {
            showNetworkAlert()
            return
        }
        
        searchState = .searching
        countryService.fetchCountries(name: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    handleError(error)
                }
            } receiveValue: { [weak self] countries in
                guard let self = self else { return }
                let filteredCountries = countries.filter { country in
                    !self.isCountryAdded(country)
                }
                searchState = .success(countries: filteredCountries)
            }
            .store(in: &cancellables)
    }
    
    func addCountry(_ country: Country) {
        guard !isCountryAdded(country) else { return }
        addedCountries.append(country)
        cacheCountry(country)
        searchText = ""
    }
    
    func removeCountry(at offsets: IndexSet) {
        let countryToRemove = offsets.map { addedCountries[$0] }
        addedCountries.remove(atOffsets: offsets)
        countryToRemove.forEach { self.unCacheCountry($0) }
    }
    
    func loadCachedCountries() {
        guard !isCountriesLoadedFromCache else { return }
        let cachedCountries = cachingManager.fetchCountries()
        addedCountries = cachedCountries
        isCountriesLoadedFromCache = true
    }
    
    private func cacheCountry(_ country: Country) {
        cachingManager.save(country: country)
    }
    
    private func unCacheCountry(_ country: Country) {
        cachingManager.delete(country: country)
    }
    
    func autoAddCountryBasedOnLocation() async {
        guard !isLaunchedBefore && addedCountries.isEmpty else { return }

        let countryCode = await locationService.requestLocationAndGetCountryCode()
        let codeToUse = countryCode ?? defaultCountryCode
        await fetchAndAddCountryByCode(codeToUse)
        isLaunchedBefore = true
    }
    
    private func fetchAndAddCountryByCode(_ code: String) async {
        guard isNetworkAvailable else {
            showNetworkAlert()
            return
        }

        countryService.fetchCountyByCode(code)
            .receive(on: DispatchQueue.main)
            //.print("$$ ")
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    handleFetchCountryByCodeError(error)
                }
            } receiveValue: { [weak self] countries in
                guard let self = self else { return }
                
                if let country = countries.first {
                    self.addedCountries.append(country)
                    cacheCountry(country)
                }
            }
            .store(in: &cancellables)
    }
    
    private func showMaxLimitAlert() {
        alertTitle = "Maximum Limit Reached"
        alertMessage = "You can only add up to \(maxCountriesLimit) countries. Please remove a country to add a new one."
        showAlert = true
    }
    
    private func showNetworkAlert() {
        alertTitle = "No Internet Connection"
        alertMessage = "Please check your internet connection and try again."
        showAlert = true
        searchState = .idle
    }
    
    private func isCountryAdded(_ country: Country) -> Bool {
        addedCountries.contains { $0.name.common == country.name.common }
    }
    
    private func handleError(_ error: APIError) {
        switch error {
        case .requestFailed:
            if !isNetworkAvailable {
                showNetworkAlert()
            } else {
                searchState = .error(message: "Network request failed. Please try again.")
            }
        case .decodingFailed:
            searchState = .error(message: "Failed to decode response.")
        case .customError(let statusCode):
            if statusCode == 404 {
                searchState = .error(message: "No countries found.")
            } else {
                searchState = .error(message: "Error: \(statusCode)")
            }
        }
    }

    private func handleFetchCountryByCodeError(_ error: APIError) {
        guard isNetworkAvailable else {
            showNetworkAlert()
            return
        }
        print("⚠️ Auto-add failed with error: \(error)")
    }
}
