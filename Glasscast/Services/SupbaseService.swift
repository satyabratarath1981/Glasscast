//
//  SupbaseService.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//

//
//  SupabaseService.swift
//  Glasscast
//
//  Services/SupabaseService.swift
//

import Foundation
import Supabase

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case emailAlreadyInUse
    case weakPassword
    case networkError
    case sessionExpired
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .userNotFound:
            return "No account found with this email"
        case .emailAlreadyInUse:
            return "An account with this email already exists"
        case .weakPassword:
            return "Password must be at least 6 characters"
        case .networkError:
            return "Network error. Please check your connection"
        case .sessionExpired:
            return "Your session has expired. Please log in again"
        case .unknown(let message):
            return message
        }
    }
}

// MARK: - Supabase Service

class SupabaseService {
    static let shared = SupabaseService()
    
    private let client: SupabaseClient
    
    private init() {
        // TODO: Replace with your Supabase project URL and anon key
        // Get these from: https://app.supabase.com/project/_/settings/api
        let supabaseURL = URL(string: "https://qzicicubrgvmmfsufdio.supabase.co")!
        let supabaseKey = "sb_publishable_crQLWdseta0reXgM0vniDQ_7lvQ8dsr"
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
    
    // MARK: - Authentication
    
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await client.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            _ = try await client.auth.signUp(
                email: email,
                password: password
            )
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func signOut() async throws {
        do {
            try await client.auth.signOut()
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await client.auth.resetPasswordForEmail(email)
        } catch {
            throw mapAuthError(error)
        }
    }
    
    func getCurrentSession() async throws -> Session? {
        do {
            let session = try await client.auth.session
            return session
        } catch {
            return nil
        }
    }
    
    func getCurrentUser() async throws -> User? {
        do {
            let session = try await client.auth.session
            return session.user
        } catch {
            return nil
        }
    }
    
    // MARK: - Error Mapping
    
    private func mapAuthError(_ error: Error) -> AuthError {
        let errorMessage = error.localizedDescription.lowercased()
        
        if errorMessage.contains("invalid") || errorMessage.contains("credentials") {
            return .invalidCredentials
        } else if errorMessage.contains("not found") || errorMessage.contains("user") {
            return .userNotFound
        } else if errorMessage.contains("already") || errorMessage.contains("exists") {
            return .emailAlreadyInUse
        } else if errorMessage.contains("password") && errorMessage.contains("weak") {
            return .weakPassword
        } else if errorMessage.contains("network") || errorMessage.contains("connection") {
            return .networkError
        } else if errorMessage.contains("expired") || errorMessage.contains("session") {
            return .sessionExpired
        } else {
            return .unknown(error.localizedDescription)
        }
    }
}
