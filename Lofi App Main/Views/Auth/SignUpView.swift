//
//  SignUpView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field {
        case email, username, password, confirmPassword
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Text("Create Account")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Join the Lo-fi Clouds community")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                        .padding(.top, 40)

                        // Form
                        VStack(spacing: 20) {
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Enter your email")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .email)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .email ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                            }

                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Username")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                TextField("", text: $username)
                                    .placeholder(when: username.isEmpty) {
                                        Text("Choose a username")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                    .textContentType(.username)
                                    .autocapitalization(.none)
                                    .focused($focusedField, equals: .username)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .username ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                            }

                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                SecureField("", text: $password)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Create a password")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .password)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .password ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )

                                // Password strength indicator
                                if !password.isEmpty {
                                    HStack(spacing: 4) {
                                        ForEach(0..<4) { index in
                                            Rectangle()
                                                .fill(index < passwordStrength ? strengthColor : Color.gray.opacity(0.3))
                                                .frame(height: 4)
                                                .clipShape(RoundedRectangle(cornerRadius: 2))
                                        }
                                    }
                                    Text(strengthText)
                                        .font(.system(size: 12))
                                        .foregroundColor(strengthColor)
                                }
                            }

                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                SecureField("", text: $confirmPassword)
                                    .placeholder(when: confirmPassword.isEmpty) {
                                        Text("Confirm your password")
                                            .foregroundColor(AppTheme.Colors.textTertiary)
                                    }
                                    .textContentType(.newPassword)
                                    .focused($focusedField, equals: .confirmPassword)
                                    .padding()
                                    .background(AppTheme.Colors.cardLight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(focusedField == .confirmPassword ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                        }
                        .padding(.horizontal, 24)

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        // Sign Up Button
                        Button(action: signUp) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Sign Up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.Colors.primary, AppTheme.Colors.secondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .disabled(isLoading || !isFormValid)
                        .opacity((isLoading || !isFormValid) ? 0.6 : 1.0)
                        .padding(.horizontal, 24)

                        // Terms
                        Text("By signing up, you agree to our **Terms of Service** and **Privacy Policy**")
                            .font(.system(size: 12))
                            .foregroundColor(AppTheme.Colors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)

                        // Divider
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                            Text("OR")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                                .padding(.horizontal, 16)
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 24)

                        // Social Login Buttons
                        VStack(spacing: 12) {
                            SocialLoginButton(
                                provider: .apple,
                                action: signUpWithApple
                            )

                            SocialLoginButton(
                                provider: .google,
                                action: signUpWithGoogle
                            )
                        }
                        .padding(.horizontal, 24)

                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Computed Properties
    private var isFormValid: Bool {
        !email.isEmpty && !username.isEmpty && !password.isEmpty && !confirmPassword.isEmpty
    }

    private var passwordStrength: Int {
        var strength = 0
        if password.count >= 8 { strength += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { strength += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { strength += 1 }
        if password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*")) != nil { strength += 1 }
        return strength
    }

    private var strengthColor: Color {
        switch passwordStrength {
        case 0...1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .gray
        }
    }

    private var strengthText: String {
        switch passwordStrength {
        case 0...1: return "Weak password"
        case 2: return "Fair password"
        case 3: return "Good password"
        case 4: return "Strong password"
        default: return ""
        }
    }

    // MARK: - Actions
    private func signUp() {
        errorMessage = nil
        isLoading = true
        focusedField = nil

        Task {
            do {
                _ = try await AuthenticationManager.shared.signUp(
                    email: email,
                    username: username,
                    password: password,
                    confirmPassword: confirmPassword
                )
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func signUpWithApple() {
        isLoading = true
        Task {
            do {
                _ = try await AuthenticationManager.shared.signInWithApple()
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func signUpWithGoogle() {
        isLoading = true
        Task {
            do {
                _ = try await AuthenticationManager.shared.signInWithGoogle()
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
