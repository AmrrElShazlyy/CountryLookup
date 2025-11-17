//
//  CachingManager.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 16/11/2025.
//

import Foundation
import SwiftData

protocol CachingManagerProtocol {
    func save(country: Country)
    func fetchCountries() -> [Country]
    func delete(country: Country)
}

final class CachingManager: CachingManagerProtocol {
    private let modelContext: ModelContext
    
    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
    }

    func save(country: Country) {
        do {
            let cachedCountry = try CachedCountry(from: country)
            modelContext.insert(cachedCountry)
            try commitOperation()
        } catch {
            print("⚠️ Failed to cache country: \(error.localizedDescription)")
        }
    }
    
    func fetchCountries() -> [Country] {
        do {
            let fetchDescriptor = FetchDescriptor<CachedCountry>(
                sortBy: [SortDescriptor(\.dateAdded, order: .forward)]
            )
            let cachedCountries = try modelContext.fetch(fetchDescriptor)
            return try cachedCountries.map { try $0.toCountry() }
        } catch {
            print("⚠️ Failed to fetch cached countries: \(error.localizedDescription)")
            return []
        }
    }
    
    func delete(country: Country) {
        do {
            let fetchDescriptor = FetchDescriptor<CachedCountry>(
                predicate: #Predicate { $0.commonName == country.name.common }
            )
            let cachedCountries = try modelContext.fetch(fetchDescriptor)
            cachedCountries.forEach { modelContext.delete($0) }
            try commitOperation()
        } catch {
            print("⚠️ Failed to delete cached country: \(error.localizedDescription)")
        }
    }

    private func commitOperation() throws {
        if modelContext.hasChanges {
            try modelContext.save()
        }
    }
}
