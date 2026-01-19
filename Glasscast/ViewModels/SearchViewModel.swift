//
//  SearchViewModel.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


import SwiftUI
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [CitySearchResult] = []
    @Published var recentSearches: [CitySearchResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private var searchTask: Task<Void, Never>?
    
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Search Cities
    
    func searchCities(query: String) async {
        // Cancel previous search
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            // Debounce
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            isLoading = true
            errorMessage = nil
            
            defer { isLoading = false }
            
            do {
                let results = try await weatherService.searchCities(query: query)
                
                guard !Task.isCancelled else { return }
                
                searchResults = results
            } catch {
                guard !Task.isCancelled else { return }
                
                if let weatherError = error as? WeatherError {
                    errorMessage = weatherError.errorDescription
                } else {
                    errorMessage = "Failed to search cities"
                }
                searchResults = []
            }
        }
        
        await searchTask?.value
    }
    
    // MARK: - Select City
    
    func selectCity(_ city: CitySearchResult) {
        addToRecentSearches(city)
        
        // Post notification for weather update
        NotificationCenter.default.post(
            name: NSNotification.Name("SelectedCityChanged"),
            object: city
        )
    }
    
    // MARK: - Recent Searches
    
    func loadRecentSearches() {
        if let data = UserDefaults.standard.data(forKey: "recentSearches"),
           let decoded = try? JSONDecoder().decode([CitySearchResult].self, from: data) {
            recentSearches = decoded
        } else {
            recentSearches = []
        }
    }
    
    private func addToRecentSearches(_ city: CitySearchResult) {
        recentSearches.removeAll { $0.id == city.id }
        recentSearches.insert(city, at: 0)
        
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
        
        if let encoded = try? JSONEncoder().encode(recentSearches) {
            UserDefaults.standard.set(encoded, forKey: "recentSearches")
        }
    }
    
    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
}
