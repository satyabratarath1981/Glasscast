//
//  SettingsView.swift
//  Glasscast
//
//  Created by Satyabrata Rath on 18/01/26.
//


import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.15, blue: 0.25),
                    Color(red: 0.15, green: 0.2, blue: 0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                header
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Unit Preferences
                        unitPreferencesSection
                        
                        // App Settings
                        appSettingsSection
                        
                        // Support
                        supportSection
                        
                        // Log Out Button
                        logOutButton
                        
                        // Version Info
                        versionInfo
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            
            Spacer()
            
            Text("Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
            
            Spacer()
            
            // Invisible spacer for centering
            Image(systemName: "chevron.left")
                .font(.title3)
                .opacity(0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }
    
    // MARK: - Unit Preferences Section
    
    private var unitPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("UNIT PREFERENCES")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        viewModel.selectedUnit = .celsius
                    }) {
                        Text("Celsius")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(viewModel.selectedUnit == .celsius ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.selectedUnit == .celsius ? .blue : .clear)
                            )
                    }
                    
                    Button(action: {
                        viewModel.selectedUnit = .fahrenheit
                    }) {
                        Text("Fahrenheit")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(viewModel.selectedUnit == .fahrenheit ? .white : .white.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(viewModel.selectedUnit == .fahrenheit ? .blue : .clear)
                            )
                    }
                }
                .padding(4)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - App Settings Section
    
    private var appSettingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("APP SETTINGS")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    iconColor: .blue,
                    title: "Notifications",
                    showChevron: true
                ) {
                    // Navigate to notifications
                }
                
                Divider()
                    .background(.white.opacity(0.1))
                    .padding(.leading, 70)
                
                settingsRow(
                    icon: "cylinder.fill",
                    iconColor: .blue,
                    title: "Weather Data Source",
                    subtitle: "Apple\nWeather",
                    showChevron: true
                ) {
                    // Navigate to data source
                }
                
                Divider()
                    .background(.white.opacity(0.1))
                    .padding(.leading, 70)
                
                settingsRow(
                    icon: "lock.fill",
                    iconColor: .blue,
                    title: "Privacy & Security",
                    showChevron: true
                ) {
                    // Navigate to privacy
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Support Section
    
    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SUPPORT")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: "questionmark.circle.fill",
                    iconColor: .gray,
                    title: "Help Center",
                    showChevron: true
                ) {
                    // Navigate to help
                }
                
                Divider()
                    .background(.white.opacity(0.1))
                    .padding(.leading, 70)
                
                settingsRow(
                    icon: "envelope.fill",
                    iconColor: .gray,
                    title: "Contact Us",
                    showChevron: true
                ) {
                    // Navigate to contact
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Settings Row
    
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String? = nil,
        showChevron: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Log Out Button
    
    private var logOutButton: some View {
        Button(action: {
            viewModel.showLogoutAlert = true
        }) {
            Text("Log Out")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.red.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .alert("Log Out", isPresented: $viewModel.showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                Task {
                    await viewModel.logout()
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    // MARK: - Version Info
    
    private var versionInfo: some View {
        VStack(spacing: 8) {
            Text("GLASSCAST v2.4.0")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.3))
            
            Text("Crafted with precision")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.2))
        }
        .padding(.top, 32)
        .padding(.bottom, 20)
    }
}

#Preview {
    SettingsView()
}
