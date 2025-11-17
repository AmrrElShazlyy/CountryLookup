//
//  CountryDetailsView.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 14/11/2025.
//

import SwiftUI

struct CountryDetailsView: View {
    let country: Country
    
    var body: some View {
        VStack(spacing: 24) {
            flag
            countryName
            countryInfo
            Spacer()
        }
        .padding(.top, 32)
        .navigationTitle(country.name.common)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var flag: some View {
        Text(country.flag)
            .font(.system(size: 100))
    }
    
    var countryName: some View {
        VStack(spacing: 8) {
            Text(country.name.common)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(country.name.official)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    var countryInfo: some View {
        VStack(spacing: 16) {
            DetailRow(
                icon: "building.2.fill",
                title: "Capital",
                value: country.capital.first ?? "NA"
            )
            
            if let currency = country.currencies.first?.value {
                let currencyText = "\(currency.name) (\(currency.symbol))"
                DetailRow(
                    icon: "dollarsign.circle.fill",
                    title: "Currency",
                    value: currencyText
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Detail Row Component
struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizedToFill(width: 24, height: 24)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationStack {
        CountryDetailsView(
            country: Country(
                name: CountryName(common: "Egypt", official: "Egypt"),
                currencies: ["EGP" : CountryCurrency(
                    name: "Egyptian Pound",
                    symbol: "$"
                )],
                capital: ["Cairo"],
                flag: "🏳️"
            )
        )
    }
}
