//
//  SocialLoginButton.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct SocialLoginButton: View {
    enum Provider {
        case apple
        case google

        var title: String {
            switch self {
            case .apple: return "Continue with Apple"
            case .google: return "Continue with Google"
            }
        }

        var icon: String {
            switch self {
            case .apple: return "apple.logo"
            case .google: return "g.circle.fill"
            }
        }

        var backgroundColor: Color {
            switch self {
            case .apple: return Color.white
            case .google: return Color.white
            }
        }

        var textColor: Color {
            switch self {
            case .apple: return Color.black
            case .google: return Color.black
            }
        }
    }

    let provider: Provider
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: provider.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(provider.textColor)

                Text(provider.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(provider.textColor)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(provider.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

#Preview {
    VStack(spacing: 16) {
        SocialLoginButton(provider: .apple) {
            print("Apple login")
        }

        SocialLoginButton(provider: .google) {
            print("Google login")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
