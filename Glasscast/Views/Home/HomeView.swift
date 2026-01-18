//
//  Home.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//

//
//  HomeView.swift
//  Glasscast
//
//  Views/Home/HomeView.swift
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var showSearch = false
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.9),
                    Color(red: 0.3, green: 0.5, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header
                    
                    if viewModel.isLoading && viewModel.currentWeather == nil {
                        loadingView
                    } else if let error = viewModel.errorMessage {
                        errorView(message: error)
                    } else if let weather = viewModel.currentWeather {
                        // Current Weather
                        currentWeatherSection(weather: weather)
                        
                        // High/Low
                        highLowSection(weather: weather)
                        
                        // 5-Day Forecast
                        if !viewModel.forecast.isEmpty {
                            forecastSection
                        }
                        
                        // More Details Button
                        moreDetailsButton
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 60)
            }
            .scrollIndicators(.hidden)
            .refreshable {
                await viewModel.fetchWeather()
            }
            
            // Bottom Navigation
            VStack {
                Spacer()
                bottomNavigation
            }
        }
        .sheet(isPresented: $showSearch) {
            SearchView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .task {
            await viewModel.fetchWeather()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelectedCityChanged"))) { notification in
            if let city = notification.object as? CitySearchResult {
                Task {
                    await viewModel.fetchWeatherForCity(city)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TemperatureUnitChanged"))) { _ in
            Task {
                await viewModel.fetchWeather()
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button(action: {
                // Menu action
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Text("Glasscast")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            Button(action: {
                showSearch = true
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Current Weather Section
    
    private func currentWeatherSection(weather: CurrentWeather) -> some View {
        VStack(spacing: 16) {
            // Weather Icon
            Image(systemName: weather.icon)
                .font(.system(size: 80))
                .foregroundStyle(.white)
                .symbolRenderingMode(.multicolor)
            
            // Temperature
            Text("\(Int(weather.temperature))°")
                .font(.system(size: 120, weight: .thin))
                .foregroundStyle(.white)
            
            // Location
            Text(weather.location)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(.white)
            
            // Description
            Text(weather.description)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.top, 20)
    }
    
    // MARK: - High/Low Section
    
    private func highLowSection(weather: CurrentWeather) -> some View {
        HStack(spacing: 16) {
            // High
            VStack(spacing: 8) {
                Text("HIGH")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("\(Int(weather.high))°")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            )
            
            // Low
            VStack(spacing: 8) {
                Text("LOW")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.7))
                
                Text("\(Int(weather.low))°")
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            )
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Forecast Section
    
    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("5-DAY FORECAST")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.forecast) { day in
                        forecastCard(day: day)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private func forecastCard(day: ForecastDay) -> some View {
        VStack(spacing: 16) {
            Text(day.dayOfWeek)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.8))
            
            Image(systemName: day.icon)
                .font(.system(size: 32))
                .foregroundStyle(.white)
                .symbolRenderingMode(.multicolor)
                .frame(height: 40)
            
            Text("\(Int(day.high))°")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Text("\(Int(day.low))°")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(width: 100)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(0.6)
        )
    }
    
    // MARK: - More Details Button
    
    private var moreDetailsButton: some View {
        Button(action: {
            // Navigate to details
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.up")
                    .font(.caption)
                Text("MORE DETAILS")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(.white.opacity(0.3), lineWidth: 1)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(.ultraThinMaterial)
                            .opacity(0.4)
                    )
            )
        }
        .padding(.top, 16)
    }
    
    // MARK: - Bottom Navigation
    
    private var bottomNavigation: some View {
        HStack(spacing: 0) {
            Button(action: {}) {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            
            Button(action: {}) {
                Image(systemName: "square.grid.2x2")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
            
            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(.ultraThinMaterial)
                .opacity(0.7)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            Text("Loading weather...")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.white.opacity(0.8))
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Retry") {
                Task {
                    await viewModel.fetchWeather()
                }
            }
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 100)
        .padding(.horizontal, 24)
    }
}

#Preview {
    HomeView()
}
