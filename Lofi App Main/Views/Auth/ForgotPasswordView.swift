//
//  ForgotPasswordView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @FocusState private var isEmailFocused: Bool

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 60))
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding(.top, 60)

                            Text("Forgot Password?")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Enter your email address and we'll send you instructions to reset your password")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

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
                                .focused($isEmailFocused)
                                .padding()
                                .background(AppTheme.Colors.cardLight)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isEmailFocused ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 24)

                        // Error/Success Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        if let successMessage = successMessage {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(successMessage)
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 24)
                        }

                        // Send Button
                        Button(action: sendResetEmail) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Send Reset Link")
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
                        .disabled(isLoading || email.isEmpty)
                        .opacity((isLoading || email.isEmpty) ? 0.6 : 1.0)
                        .padding(.horizontal, 24)

                        // Back to Login
                        Button(action: { dismiss() }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.left")
                                Text("Back to Login")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppTheme.Colors.primary)
                        }
                        .padding(.top, 16)

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

    // MARK: - Actions
    private func sendResetEmail() {
        errorMessage = nil
        successMessage = nil
        isLoading = true
        isEmailFocused = false

        Task {
            do {
                try await AuthenticationManager.shared.sendPasswordResetEmail(email: email)
                await MainActor.run {
                    isLoading = false
                    successMessage = "Reset link sent! Check your email."
                    // Auto dismiss after 2 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        dismiss()
                    }
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
    ForgotPasswordView()
}
