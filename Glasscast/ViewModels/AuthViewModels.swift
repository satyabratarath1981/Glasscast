//
//  AuthViewModels.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//

//
//  AuthViewModel.swift
//  Glasscast
//
//  ViewModels/AuthViewModel.swift
//

import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var emailError: String?
    @Published var passwordError: String?
    
    private let supabaseService = SupabaseService.shared
    
    // MARK: - Validation
    
    private func validateEmail(_ email: String) -> Bool {
        emailError = nil
        
        guard !email.isEmpty else {
            emailError = "Email is required"
            return false
        }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        guard emailPredicate.evaluate(with: email) else {
            emailError = "Please enter a valid email"
            return false
        }
        
        return true
    }
    
    private func validatePassword(_ password: String) -> Bool {
        passwordError = nil
        
        guard !password.isEmpty else {
            passwordError = "Password is required"
            return false
        }
        
        guard password.count >= 6 else {
            passwordError = "Password must be at least 6 characters"
            return false
        }
        
        return true
    }
    
    private func validate(email: String, password: String) -> Bool {
        let emailValid = validateEmail(email)
        let passwordValid = validatePassword(password)
        return emailValid && passwordValid
    }
    
    // MARK: - Authentication Methods
    
    func login(email: String, password: String) async {
        // Clear previous errors
        errorMessage = nil
        emailError = nil
        passwordError = nil
        
        // Validate inputs
        guard validate(email: email, password: password) else {
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseService.signIn(email: email, password: password)
            isAuthenticated = true
            errorMessage = nil
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    func signUp(email: String, password: String) async {
        // Clear previous errors
        errorMessage = nil
        emailError = nil
        passwordError = nil
        
        // Validate inputs
        guard validate(email: email, password: password) else {
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseService.signUp(email: email, password: password)
            errorMessage = nil
            // Note: User might need to verify email before being authenticated
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "An unexpected error occurred. Please try again."
        }
        
        isLoading = false
    }
    
    func signOut() async {
        isLoading = true
        
        do {
            try await supabaseService.signOut()
            isAuthenticated = false
            errorMessage = nil
        } catch {
            errorMessage = "Failed to sign out. Please try again."
        }
        
        isLoading = false
    }
    
    func resetPassword(email: String) async {
        emailError = nil
        errorMessage = nil
        
        guard validateEmail(email) else {
            return
        }
        
        isLoading = true
        
        do {
            try await supabaseService.resetPassword(email: email)
            errorMessage = nil
            // Show success message to user
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to send reset email. Please try again."
        }
        
        isLoading = false
    }
    
    func checkAuthStatus() async {
        do {
            let session = try await supabaseService.getCurrentSession()
            isAuthenticated = session != nil
        } catch {
            isAuthenticated = false
        }
    }
}
