//
//  SearchView.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//

//
//  SearchView.swift
//  Glasscast
//
//  Views/Search/SearchView.swift
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.25, blue: 0.55),
                    Color(red: 0.2, green: 0.3, blue: 0.65)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                // Search Bar
                searchBar
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Results Section
                        if !viewModel.searchText.isEmpty {
                            resultsSection
                        }
                        
                        // Recent Searches Section
                        if !viewModel.recentSearches.isEmpty {
                            recentSearchesSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 24)
                }
                .scrollIndicators(.hidden)
                
                // Bottom Navigation
                bottomNavigation
            }
        }
        .onAppear {
            isSearchFocused = true
            viewModel.loadRecentSearches()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Text("Search")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button("Cancel") {
                dismiss()
            }
            .font(.body)
            .foregroundStyle(.blue)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Search Bar
    
    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))
            
            TextField("", text: $viewModel.searchText)
                .placeholder(when: viewModel.searchText.isEmpty) {
                    Text("New York")
                        .foregroundStyle(.white.opacity(0.4))
                }
                .foregroundStyle(.white)
                .focused($isSearchFocused)
                .autocapitalization(.words)
                .textInputAutocapitalization(.words)
                .onChange(of: viewModel.searchText) { oldValue, newValue in
                    Task {
                        await viewModel.searchCities(query: newValue)
                    }
                }
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.searchResults = []
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white.opacity(0.15))
        )
        .padding(.horizontal, 24)
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RESULTS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 24)
            
            if viewModel.isLoading {
                loadingView
            } else if viewModel.searchResults.isEmpty && !viewModel.searchText.isEmpty {
                noResultsView
            } else {
                ForEach(viewModel.searchResults) { result in
                    cityResultCard(result: result)
                }
            }
        }
    }
    
    private func cityResultCard(result: CitySearchResult) -> some View {
        Button(action: {
            viewModel.selectCity(result)
            dismiss()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.displayName)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    
                    Text(result.condition)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                Text("\(Int(result.temperature))°")
                    .font(.system(size: 32, weight: .regular))
                    .foregroundStyle(.white)
                
                Image(systemName: "chevron.right")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.leading, 8)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .opacity(0.5)
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Recent Searches Section
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("RECENT SEARCHES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.6))
                .padding(.horizontal, 24)
            
            ForEach(viewModel.recentSearches) { recent in
                cityResultCard(result: recent)
            }
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .tint(.white)
            Spacer()
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - No Results View
    
    private var noResultsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundStyle(.white.opacity(0.5))
            
            Text("No results found")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "map")
                        .font(.title3)
                    Text("LOCATIONS")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.title3)
                    Text("SEARCH")
                        .font(.caption2)
                }
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
            }
            
            Button(action: {}) {
                VStack(spacing: 4) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                    Text("SETTINGS")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 24)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.7)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - TextField Placeholder Extension

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    SearchView()
}
