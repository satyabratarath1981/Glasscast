//
//  Untitled.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


//
//  WeatherService.swift
//  Glasscast
//
//  Services/WeatherService.swift
//

import Foundation

// MARK: - Weather Models

struct CurrentWeather: Identifiable {
    let id = UUID()
    let temperature: Double
    let high: Double
    let low: Double
    let description: String
    let icon: String
    let location: String
}

struct ForecastDay: Identifiable {
    let id = UUID()
    let dayOfWeek: String
    let high: Double
    let low: Double
    let icon: String
}

struct CitySearchResult: Identifiable, Codable {
    let id: String
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    let temperature: Double
    let condition: String
    
    var displayName: String {
        "\(name), \(country)"
    }
}

// MARK: - Weather Service

actor WeatherService {
    static let shared = WeatherService()
    
    private let apiKey = "YOUR_API_KEY_HERE"
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    private let session: URLSession
    
    // Simple cache to reduce API calls
    private var weatherCache: [String: (data: CurrentWeather, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Fetch Current Weather
    
    func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> CurrentWeather {
        let cacheKey = "\(latitude),\(longitude)"
        
        // Check cache
        if let cached = weatherCache[cacheKey],
           Date().timeIntervalSince(cached.timestamp) < cacheTimeout {
            return cached.data
        }
        
        let urlString = "\(baseURL)/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.serverError
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw WeatherError.invalidAPIKey
        case 404:
            throw WeatherError.locationNotFound
        case 429:
            throw WeatherError.rateLimitExceeded
        default:
            throw WeatherError.serverError
        }
        
        let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
        
        let currentWeather = CurrentWeather(
            temperature: weatherResponse.main.temp,
            high: weatherResponse.main.temp_max,
            low: weatherResponse.main.temp_min,
            description: weatherResponse.weather.first?.main ?? "Clear",
            icon: mapWeatherIcon(weatherResponse.weather.first?.main ?? "Clear"),
            location: weatherResponse.name
        )
        
        // Cache the result
        weatherCache[cacheKey] = (currentWeather, Date())
        
        return currentWeather
    }
    
    // MARK: - Fetch 5-Day Forecast
    
    func fetchForecast(latitude: Double, longitude: Double) async throws -> [ForecastDay] {
        let urlString = "\(baseURL)/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.serverError
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw WeatherError.invalidAPIKey
        case 404:
            throw WeatherError.locationNotFound
        case 429:
            throw WeatherError.rateLimitExceeded
        default:
            throw WeatherError.serverError
        }
        
        let forecastResponse = try JSONDecoder().decode(ForecastResponse.self, from: data)
        
        return processForecast(forecastResponse.list)
    }
    
    // MARK: - Search Cities
    
    func searchCities(query: String) async throws -> [CitySearchResult] {
        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(query)&limit=5&appid=\(apiKey)"
        
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURL) else {
            throw WeatherError.invalidURL
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.serverError
        }
        
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            throw WeatherError.invalidAPIKey
        case 404:
            return [] // No results found
        case 429:
            throw WeatherError.rateLimitExceeded
        default:
            throw WeatherError.serverError
        }
        
        let locations = try JSONDecoder().decode([GeocodingResult].self, from: data)
        
        // Fetch weather for each location (limit to 3 to reduce API calls)
        var results: [CitySearchResult] = []
        
        for location in locations.prefix(3) {
            do {
                let weather = try await fetchCurrentWeather(
                    latitude: location.lat,
                    longitude: location.lon
                )
                
                let result = CitySearchResult(
                    id: "\(location.lat),\(location.lon)",
                    name: location.name,
                    country: location.country,
                    latitude: location.lat,
                    longitude: location.lon,
                    temperature: weather.temperature,
                    condition: weather.description
                )
                
                results.append(result)
            } catch {
                continue
            }
        }
        
        return results
    }
    
    // MARK: - Helper Methods
    
    private func processForecast(_ list: [ForecastItem]) -> [ForecastDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        var dailyForecasts: [Date: (high: Double, low: Double, icon: String)] = [:]
        
        for item in list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayStart = calendar.startOfDay(for: date)
            
            guard dayStart > today else { continue }
            
            if var existing = dailyForecasts[dayStart] {
                existing.high = max(existing.high, item.main.temp_max)
                existing.low = min(existing.low, item.main.temp_min)
                dailyForecasts[dayStart] = existing
            } else {
                dailyForecasts[dayStart] = (
                    high: item.main.temp_max,
                    low: item.main.temp_min,
                    icon: item.weather.first?.main ?? "Clear"
                )
            }
        }
        
        let sortedDays = dailyForecasts.keys.sorted()
        return sortedDays.prefix(5).compactMap { date in
            guard let forecast = dailyForecasts[date] else { return nil }
            
            let dayName = formatDayOfWeek(date)
            
            return ForecastDay(
                dayOfWeek: dayName,
                high: forecast.high,
                low: forecast.low,
                icon: mapWeatherIcon(forecast.icon)
            )
        }
    }
    
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }
    
    private func mapWeatherIcon(_ condition: String) -> String {
        switch condition.lowercased() {
        case "clear":
            return "sun.max.fill"
        case "clouds":
            return "cloud.fill"
        case "rain", "drizzle":
            return "cloud.rain.fill"
        case "thunderstorm":
            return "cloud.bolt.fill"
        case "snow":
            return "cloud.snow.fill"
        case "mist", "fog", "haze":
            return "cloud.fog.fill"
        default:
            return "cloud.sun.fill"
        }
    }
    
    // MARK: - Cache Management
    
    func clearCache() {
        weatherCache.removeAll()
    }
}

// MARK: - API Response Models

private struct WeatherResponse: Codable {
    let name: String
    let main: MainData
    let weather: [WeatherCondition]
}

private struct MainData: Codable {
    let temp: Double
    let temp_min: Double
    let temp_max: Double
}

private struct WeatherCondition: Codable {
    let main: String
    let description: String
}

private struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

private struct ForecastItem: Codable {
    let dt: TimeInterval
    let main: MainData
    let weather: [WeatherCondition]
}

private struct GeocodingResult: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}

// MARK: - Weather Error

enum WeatherError: LocalizedError {
    case invalidURL
    case serverError
    case decodingError
    case networkError
    case invalidAPIKey
    case locationNotFound
    case rateLimitExceeded
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid request"
        case .serverError:
            return "Server error. Please try again later."
        case .decodingError:
            return "Failed to process weather data"
        case .networkError:
            return "No internet connection"
        case .invalidAPIKey:
            return "API key is invalid. Please check configuration."
        case .locationNotFound:
            return "Location not found"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        }
    }
}
