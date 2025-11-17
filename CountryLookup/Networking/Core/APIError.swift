//
//  APIError.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 13/11/2025.
//

import Foundation

public enum APIError: Error, Equatable {
    case requestFailed
    case decodingFailed
    case customError(statusCode: Int)
}
