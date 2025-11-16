//
//  CountrySearchView.swift
//  CountryLookup
//
//  Created by Amr El Shazly on 14/11/2025.
//

import SwiftUI
import SwiftData

struct CountrySearchView: View {
    // MARK: - Private Properties
    @StateObject private var viewModel: CountrySearchViewModel
    private let title = "Countries"
    private let searchBarPrompt = "Search countries..."
    
    init(modelContainer: ModelContainer) {
        _viewModel = StateObject(
            wrappedValue: CountrySearchViewModel(modelContainer: modelContainer)
        )
    }

    // MARK: body
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.addedCountries.isEmpty {
                    emptyState
                } else {
                    countriesList
                }
                
                if !viewModel.searchText.isEmpty {
                    searchResultsOverlay
                }
            }
            .navigationTitle(title)
            .searchable(
                text: $viewModel.searchText,
                placement: .automatic,
                prompt: searchBarPrompt
            )
            .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                Button("OK", role: .cancel) {
                    viewModel.searchText = ""
                }
            } message: {
                Text(viewModel.alertMessage)
            }
            .task {
                viewModel.loadCachedCountries()
                await viewModel.autoAddCountryBasedOnLocation()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .resizedToFill(width: 64, height: 64)
                .foregroundColor(.blue)
            
            Text("No Countries Added")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search and add countries to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var countriesList: some View {
        List {
            Section {
                ForEach(viewModel.addedCountries, id: \.name.common) { country in
                    NavigationLink(value: country) {
                        CountryRowView(
                            flag: country.flag,
                            name: country.name.common
                        )
                    }
                }
                .onDelete(perform: viewModel.removeCountry)
            } footer: {
                Text("\(viewModel.addedCountries.count)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Country.self) { country in
            CountryDetailsView(country: country)
        }
    }
    
    private var searchResultsOverlay: some View {
        VStack {
            searchResultsContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    @ViewBuilder
    private var searchResultsContent: some View {
        switch viewModel.searchState {
        case .idle:
            EmptyView()
        case .searching:
            searchingInProgressView
        case .success(let countries):
            searchResultsList(countries: countries)
        case .error(let message):
            searchingErrorMessageView(text: message)
        }
    }
    
    private func searchResultsList(countries: [Country]) -> some View {
        List {
            ForEach(countries, id: \.name.common) { country in
                Button {
                    viewModel.addCountry(country)
                } label: {
                    searchingRowView(
                        flag: country.flag,
                        name: country.name.common
                    )
                }
            }
        }
        .listStyle(.plain)
    }
    
    private var searchingInProgressView: some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                Text("Searching...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    private func searchingErrorMessageView(text: String) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text(text)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
        }
    }
    
    private func searchingRowView(flag: String, name: String) -> some View {
        HStack(spacing: 12) {
            Text(flag)
                .font(.system(size: 40))
            
            Text(name)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "plus.circle.fill")
                .resizedToFill(width: 24, height: 24)
                .foregroundColor(.blue)
        }
    }
}

// MARK: - Country Row View
struct CountryRowView: View {
    let flag: String
    let name: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(flag)
                .font(.system(size: 40))
            Text(name)
                .font(.title)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
//#Preview {
//    CountrySearchView(modelContainer: <#ModelContainer#>)
//}
