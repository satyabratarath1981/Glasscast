//
//  SettingViewModel.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//

import SwiftUI
import UserNotifications
import Combine

enum TemperatureUnit: String, Codable {
    case celsius = "metric"
    case fahrenheit = "imperial"
    
    var displayName: String {
        switch self {
        case .celsius:
            return "Celsius"
        case .fahrenheit:
            return "Fahrenheit"
        }
    }
    
    var symbol: String {
        switch self {
        case .celsius:
            return "°C"
        case .fahrenheit:
            return "°F"
        }
    }
}

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var selectedUnit: TemperatureUnit {
        didSet {
            saveUnitPreference()
        }
    }
    
    @Published var notificationsEnabled = false
    @Published var showLogoutAlert = false
    @Published var isLoggingOut = false
    @Published var logoutError: String?
    
    private let authService = SupabaseService.shared
    
    init() {
        if let savedUnit = UserDefaults.standard.string(forKey: "temperatureUnit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            self.selectedUnit = unit
        } else {
            self.selectedUnit = .celsius
        }
        
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
    }
    
    // MARK: - Unit Preferences
    
    private func saveUnitPreference() {
        UserDefaults.standard.set(selectedUnit.rawValue, forKey: "temperatureUnit")
        
        NotificationCenter.default.post(
            name: NSNotification.Name("TemperatureUnitChanged"),
            object: selectedUnit
        )
    }
    
    func getTemperatureUnit() -> TemperatureUnit {
        return selectedUnit
    }
    
    // MARK: - Notifications
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: "notificationsEnabled")
        
        if enabled {
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            Task { @MainActor in
                self.notificationsEnabled = granted
                UserDefaults.standard.set(granted, forKey: "notificationsEnabled")
            }
        }
    }
    
    // MARK: - Logout
    
    func logout() async {
        isLoggingOut = true
        logoutError = nil
        
        do {
            try await authService.signOut()
            
            clearUserData()
            
            NotificationCenter.default.post(
                name: NSNotification.Name("UserDidLogout"),
                object: nil
            )
        } catch {
            logoutError = "Failed to log out. Please try again."
        }
        
        isLoggingOut = false
    }
    
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "recentSearches")
    }
    
    // MARK: - App Info
    
    func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return "v\(version) (\(build))"
        }
        return "v2.4.0"
    }
}
