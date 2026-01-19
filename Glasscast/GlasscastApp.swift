//
//  GlasscastApp.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


import SwiftUI
import Combine
internal import Auth

@main
struct GlasscastApp: App {
    @StateObject private var appCoordinator = AppCoordinator()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appCoordinator.isLoading {
                    // Show loading screen
                    LoadingScreen()
                } else if appCoordinator.isAuthenticated {
                    HomeView()
                        .transition(.opacity)
                        .id("home") // Force view refresh
                } else {
                    LoginView()
                        .transition(.opacity)
                        .id("login") // Force view refresh
                }
            }
            .animation(.easeInOut(duration: 0.4), value: appCoordinator.isAuthenticated)
            .animation(.easeInOut(duration: 0.3), value: appCoordinator.isLoading)
            .task {
                await appCoordinator.checkAuthStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogin"))) { _ in
                print("📢 App received UserDidLogin notification")
                Task {
                    await appCoordinator.handleLogin()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogout"))) { _ in
                print("📢 App received UserDidLogout notification")
                appCoordinator.handleLogout()
            }
        }
    }
}

// MARK: - Loading Screen

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.5),
                    Color(red: 0.3, green: 0.2, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                
                Text("Glasscast")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
            }
        }
    }
}

// MARK: - App Coordinator

@MainActor
class AppCoordinator: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = true
    
    private let authService = SupabaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupNotificationObservers()
    }
    
    private func setupNotificationObservers() {
        // Listen for login notifications
        NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogin"))
            .sink { [weak self] _ in
                print("🔔 AppCoordinator: Login notification received in observer")
                Task { @MainActor [weak self] in
                    await self?.handleLogin()
                }
            }
            .store(in: &cancellables)
        
        // Listen for logout notifications
        NotificationCenter.default.publisher(for: NSNotification.Name("UserDidLogout"))
            .sink { [weak self] _ in
                print("🔔 AppCoordinator: Logout notification received in observer")
                self?.handleLogout()
            }
            .store(in: &cancellables)
    }
    
    func checkAuthStatus() async {
        print("🔍 Checking auth status...")
        isLoading = true
        
        // Small delay to ensure UI is ready
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        do {
            let session = try await authService.getCurrentSession()
            let hasSession = session != nil
            
            print("📊 Session check result: \(hasSession ? "Has session" : "No session")")
            
            if let session = session {
                print("✅ User ID: \(session.user.id)")
                print("✅ Email: \(session.user.email ?? "N/A")")
            }
            
            // Update authentication state
            withAnimation {
                isAuthenticated = hasSession
            }
        } catch {
            print("❌ Session check error: \(error)")
            withAnimation {
                isAuthenticated = false
            }
        }
        
        isLoading = false
        print("🏁 Auth check complete. isAuthenticated: \(isAuthenticated)")
    }
    
    func handleLogin() async {
        print("🔐 handleLogin called")
        
        // Wait for session to be fully saved
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
        
        // Re-check auth status
        await checkAuthStatus()
        
        // Force authentication state update
        if !isAuthenticated {
            print("⚠️ Session not found after login, trying again...")
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 more seconds
            await checkAuthStatus()
        }
        
        // Manual override if session exists but flag not set
        do {
            let session = try await authService.getCurrentSession()
            if session != nil && !isAuthenticated {
                print("🔧 Forcing authentication state to true")
                withAnimation {
                    isAuthenticated = true
                }
            }
        } catch {
            print("❌ Manual check failed: \(error)")
        }
        
        print("🏁 handleLogin complete. isAuthenticated: \(isAuthenticated)")
    }
    
    func handleLogout() {
        print("🚪 handleLogout called")
        withAnimation {
            isAuthenticated = false
        }
    }
}
