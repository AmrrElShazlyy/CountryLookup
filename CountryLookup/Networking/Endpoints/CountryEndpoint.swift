//
//  CountryEndpoint.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation

enum CountryEndpoint: APIEndpoint {
    case country(name: String)
    case countryCode(code: String)
    
    var baseURL: URL {
        guard let url = URL(string: "https://restcountries.com/v3.1/") else {
            fatalError("Invalid base URL string.")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .country(let name):
            return "name/\(name.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? name)"
        case .countryCode(code: let code):
            return "alpha/\(code.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? code)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .country, .countryCode:
            return .get
        }
    }
    
    var headers: [String : String]? {
        nil
    }
    
    var body: Data? {
        nil
    }
}
