//
//  FeedbackView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var sessionManager = SessionManager.shared

    @State private var selectedCategory: FeedbackCategory = .general
    @State private var feedbackText = ""
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Field?

    enum Field {
        case email, feedback
    }

    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.Gradients.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.open.fill")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.Colors.primary)
                                .padding(.top, 20)

                            Text("Send Us Feedback")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("We'd love to hear from you! Your feedback helps us improve.")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }

                        // Category Picker
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)

                            HStack(spacing: 12) {
                                ForEach(FeedbackCategory.allCases, id: \.self) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 24)

                        // Email Field (if not logged in)
                        if sessionManager.currentUser?.isGuest ?? true {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppTheme.Colors.textSecondary)

                                TextField("", text: $email)
                                    .placeholder(when: email.isEmpty) {
                                        Text("your@email.com")
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
                            .padding(.horizontal, 24)
                        }

                        // Feedback Text Area
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Your Feedback")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(AppTheme.Colors.textSecondary)

                            ZStack(alignment: .topLeading) {
                                if feedbackText.isEmpty {
                                    Text("Tell us what's on your mind...")
                                        .foregroundColor(AppTheme.Colors.textTertiary)
                                        .padding()
                                        .padding(.top, 8)
                                }

                                TextEditor(text: $feedbackText)
                                    .focused($focusedField, equals: .feedback)
                                    .scrollContentBackground(.hidden)
                                    .padding(8)
                                    .frame(height: 200)
                            }
                            .background(AppTheme.Colors.cardLight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedField == .feedback ? AppTheme.Colors.primary : Color.clear, lineWidth: 2)
                            )

                            Text("\(feedbackText.count)/500")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.Colors.textTertiary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 24)

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .padding(.horizontal, 24)
                        }

                        // Submit Button
                        Button(action: submitFeedback) {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Submit Feedback")
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

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                }
            }
            .alert("Thank You!", isPresented: $showSuccess) {
                Button("Done") {
                    dismiss()
                }
            } message: {
                Text("Your feedback has been received. We'll review it shortly!")
            }
            .onAppear {
                loadUserEmail()
            }
        }
    }

    // MARK: - Computed Properties
    private var isFormValid: Bool {
        let hasEmail = !(sessionManager.currentUser?.isGuest ?? true) || !email.isEmpty
        return hasEmail && !feedbackText.isEmpty && feedbackText.count <= 500
    }

    // MARK: - Actions
    private func loadUserEmail() {
        if let user = sessionManager.currentUser, !user.isGuest {
            email = user.email
        }
    }

    private func submitFeedback() {
        errorMessage = nil
        isLoading = true
        focusedField = nil

        Task {
            // Simulate API call
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

            await MainActor.run {
                isLoading = false
                showSuccess = true
                print("📧 Feedback submitted: [\(selectedCategory.displayName)] from \(email)")
            }
        }
    }
}

// MARK: - Feedback Category
enum FeedbackCategory: String, CaseIterable {
    case bug = "Bug"
    case feature = "Feature"
    case general = "General"

    var displayName: String {
        rawValue
    }

    var icon: String {
        switch self {
        case .bug: return "ant.fill"
        case .feature: return "lightbulb.fill"
        case .general: return "message.fill"
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: FeedbackCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)

                Text(category.displayName)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? .white : AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppTheme.Colors.primary : AppTheme.Colors.cardLight)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeedbackView()
}
