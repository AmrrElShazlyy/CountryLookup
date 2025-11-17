//
//  CachedCountry.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 16/11/2025.
//

import Foundation
import  SwiftData

@Model
final class CachedCountry {
    @Attribute(.unique) var commonName: String
    var officialName: String
    var currenciesData: Data
    var capital: [String]
    var flag: String
    var dateAdded: Date
    
    init(
        commonName: String,
        officialName: String,
        currenciesData: Data,
        capital: [String],
        flag: String,
        dateAdded: Date = Date()
    ) {
        self.commonName = commonName
        self.officialName = officialName
        self.currenciesData = currenciesData
        self.capital = capital
        self.flag = flag
        self.dateAdded = dateAdded
    }
    
    convenience init (from country: Country) throws {
        let currenciesData = try JSONEncoder().encode(country.currencies)
        self.init(
            commonName: country.name.common,
            officialName: country.name.official,
            currenciesData: currenciesData,
            capital: country.capital,
            flag: country.flag
        )
    }
    
    func toCountry() throws -> Country {
        let currencies = try JSONDecoder().decode([String: CountryCurrency].self, from: currenciesData)
        return Country(
            name: CountryName(common: commonName, official: officialName),
            currencies: currencies,
            capital: capital,
            flag: flag
        )
    }
}
