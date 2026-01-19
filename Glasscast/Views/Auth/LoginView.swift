//
//  Login.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.5),
                    Color(red: 0.3, green: 0.2, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Glass Card Container
                VStack(spacing: 24) {
                    // Logo
                    Image(systemName: "cloud.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(.blue.opacity(0.3))
                        )
                    
                    // App Name
                    Text("Glasscast")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                    
                    // Welcome Text
                    VStack(spacing: 8) {
                        Text("Welcome back")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(.white)
                        
                        Text("Log in to view your local atmospheric glass")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.bottom, 12)
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                        
                        TextField("", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.95))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.emailError != nil ? .red : .clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Password")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.9))
                            
                            Spacer()
                            
                            Button("Forgot?") {
                                // Handle forgot password
                            }
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        }
                        
                        SecureField("", text: $password)
                            .textContentType(.password)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.95))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.passwordError != nil ? .red : .clear, lineWidth: 1)
                            )
                        
                        if let error = viewModel.passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    // Login Button
                    Button(action: {
                        Task {
                            await viewModel.login(email: email, password: password)
                        }
                    }) {
                        HStack(spacing: 12) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .disabled(viewModel.isLoading)
                    .padding(.top, 8)
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.red.opacity(0.1))
                            )
                    }
                    
                    // Success Message (for debugging)
                    if viewModel.loginSuccess {
                        Text("Login successful! Redirecting...")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.green.opacity(0.1))
                            )
                    }
                    
                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .foregroundStyle(.white.opacity(0.7))
                        Button("Sign up") {
                            // Handle sign up navigation
                        }
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    }
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
                )
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer Links
                HStack(spacing: 40) {
                    Button("Privacy Policy") {
                        // Handle privacy policy
                    }
                    Button("Terms of Service") {
                        // Handle terms of service
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom, 40)
            }
        }
        .onChange(of: viewModel.loginSuccess) { oldValue, newValue in
            if newValue {
                print("📢 LoginView detected login success")
            }
        }
    }
}

#Preview {
    LoginView()
}
