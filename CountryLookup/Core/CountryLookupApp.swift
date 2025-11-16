//
//  CountryLookupApp.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import SwiftUI
import SwiftData

@main
struct CountryLookupApp: App {
    let countryModelContainer: ModelContainer

    init() {
        let schema = Schema([CachedCountry.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        do {
            countryModelContainer = try ModelContainer(
                for: schema,
                configurations: modelConfiguration
            )
        } catch {
            fatalError("⚠️⚠️⚠️ Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            CountrySearchView(modelContainer: countryModelContainer)
        }
    }
}
