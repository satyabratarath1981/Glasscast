//
//  WeatherViewModel.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


import SwiftUI
import CoreLocation
import Combine

@MainActor
class WeatherViewModel: NSObject, ObservableObject {
    @Published var currentWeather: CurrentWeather?
    @Published var forecast: [ForecastDay] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let weatherService = WeatherService.shared
    private var locationManager: CLLocationManager?
    private var currentLocation: CLLocation?
    private var fetchTask: Task<Void, Never>?
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    deinit {
        fetchTask?.cancel()
        locationManager?.delegate = nil
        locationManager = nil
    }
    
    // MARK: - Setup
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    // MARK: - Public Methods
    
    func fetchWeather() async {
        // Cancel any existing fetch
        fetchTask?.cancel()
        
        fetchTask = Task {
            errorMessage = nil
            isLoading = true
            
            defer { isLoading = false }
            
            // Check cancellation
            guard !Task.isCancelled else { return }
            
            // Request location permission if needed
            if let manager = locationManager, manager.authorizationStatus == .notDetermined {
                manager.requestWhenInUseAuthorization()
            }
            
            // Request location
            locationManager?.requestLocation()
            
            // Wait for location with timeout
            let startTime = Date()
            while currentLocation == nil && Date().timeIntervalSince(startTime) < 2.0 {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
            }
            
            guard !Task.isCancelled else { return }
            
            // Use location or fallback
            let location = currentLocation ?? CLLocation(latitude: 51.5074, longitude: -0.1278)
            let cityName = await getCityName(from: location) ?? "London"
            
            await fetchWeatherForLocation(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                city: cityName
            )
        }
        
        await fetchTask?.value
    }
    
    func fetchWeatherForCity(_ city: CitySearchResult) async {
        fetchTask?.cancel()
        
        fetchTask = Task {
            errorMessage = nil
            isLoading = true
            
            defer { isLoading = false }
            
            guard !Task.isCancelled else { return }
            
            await fetchWeatherForLocation(
                latitude: city.latitude,
                longitude: city.longitude,
                city: city.name
            )
        }
        
        await fetchTask?.value
    }
    
    // MARK: - Private Methods
    
    private func fetchWeatherForLocation(latitude: Double, longitude: Double, city: String) async {
        do {
            guard !Task.isCancelled else { return }
            
            async let weatherData = weatherService.fetchCurrentWeather(
                latitude: latitude,
                longitude: longitude
            )
            
            async let forecastData = weatherService.fetchForecast(
                latitude: latitude,
                longitude: longitude
            )
            
            let (weather, forecastList) = try await (weatherData, forecastData)
            
            guard !Task.isCancelled else { return }
            
            currentWeather = CurrentWeather(
                temperature: weather.temperature,
                high: weather.high,
                low: weather.low,
                description: weather.description,
                icon: weather.icon,
                location: city
            )
            
            forecast = forecastList
            errorMessage = nil
        } catch {
            guard !Task.isCancelled else { return }
            
            if let weatherError = error as? WeatherError {
                errorMessage = weatherError.errorDescription
            } else {
                errorMessage = "Failed to fetch weather data. Please try again."
            }
            
            currentWeather = nil
            forecast = []
        }
    }
    
    private func getCityName(from location: CLLocation) async -> String? {
        do {
            let geocoder = CLGeocoder()
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.locality
        } catch {
            return nil
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewModel: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            currentLocation = locations.first
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            errorMessage = "Failed to get location. Using default location."
        }
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            if manager.authorizationStatus == .authorizedWhenInUse ||
               manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }
}
