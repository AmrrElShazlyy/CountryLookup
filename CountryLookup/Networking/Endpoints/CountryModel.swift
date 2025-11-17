//
//  CountryModel.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation

struct Country: Codable, Hashable {
    let name: CountryName
    let currencies: [String: CountryCurrency]
    let capital: [String]
    let flag: String
    
    init(
        name: CountryName,
        currencies: [String : CountryCurrency],
        capital: [String],
        flag: String
    ) {
        self.name = name
        self.currencies = currencies
        self.capital = capital
        self.flag = flag
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(CountryName.self, forKey: .name) ?? CountryName(common: "NA", official: "NA")
        self.currencies = try container.decodeIfPresent([String : CountryCurrency].self, forKey: .currencies) ?? ["NA": CountryCurrency(name: "NA", symbol: "NA")]
        self.capital = try container.decodeIfPresent([String].self, forKey: .capital) ?? ["NA"]
        self.flag = try container.decodeIfPresent(String.self, forKey: .flag) ?? "🏳️"
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name.common)
    }
    
    static func == (lhs: Country, rhs: Country) -> Bool {
        lhs.name.common == rhs.name.common
    }
}

struct CountryName: Codable, Hashable {
    let common: String
    let official: String
    
    init(common: String, official: String) {
        self.common = common
        self.official = official
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.common = try container.decodeIfPresent(String.self, forKey: .common) ?? "NA"
        self.official = try container.decodeIfPresent(String.self, forKey: .official) ?? "NA"
    }
}

struct CountryCurrency: Codable, Hashable {
    let name: String
    let symbol: String
    
    init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "NA"
        self.symbol = try container.decodeIfPresent(String.self, forKey: .symbol) ?? "NA"
    }
}
