//
//  WelcomeView.swift
//  Lofi App Main
//
//  Created by Quest on 11/5/25.
//

import SwiftUI

struct WelcomeView: View {
    @State private var showLogin = false
    @State private var showSignUp = false
    @StateObject private var sessionManager = SessionManager.shared
    @State private var animateGradient = false

    var body: some View {
        NavigationView {
            ZStack {
                // Animated background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.15, green: 0.15, blue: 0.25),
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color(red: 0.2, green: 0.15, blue: 0.3)
                    ],
                    startPoint: animateGradient ? .topLeading : .bottomLeading,
                    endPoint: animateGradient ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                .onAppear {
                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                        animateGradient = true
                    }
                }

                VStack(spacing: 40) {
                    Spacer()

                    // App Logo / Cloud Animation
                    VStack(spacing: 20) {
                        ZStack {
                            // Animated cloud shapes
                            ForEach(0..<3) { index in
                                AnimatedCloudView(imageURL: nil)
                                    .frame(width: 200, height: 150)
                                    .opacity(0.3 - Double(index) * 0.1)
                                    .offset(y: CGFloat(index) * 10)
                            }
                        }
                        .frame(height: 200)

                        VStack(spacing: 8) {
                            Text("Lo-fi Clouds")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Text("Focus. Study. Relax.")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    Spacer()

                    // Auth buttons
                    VStack(spacing: 16) {
                        // Sign Up Button
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.Colors.primary,
                                            AppTheme.Colors.secondary
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        // Login Button
                        Button(action: {
                            showLogin = true
                        }) {
                            Text("Login")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(Color.white.opacity(0.1))
                                        )
                                )
                        }

                        // Guest Button
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                AuthenticationManager.shared.continueAsGuest()
                            }
                        }) {
                            Text("Continue as Guest")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLogin) {
                LoginView()
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
        }
    }
}

#Preview {
    WelcomeView()
}
