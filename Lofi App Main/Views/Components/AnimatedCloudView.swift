//
//  AnimatedCloudView.swift
//  Lofi App Main
//
//  Created by Quest on 11/4/25.
//

import SwiftUI

struct AnimatedCloudView: View {
    @State private var animateCloud = false
    let imageURL: String?

    var body: some View {
        ZStack {
            // Background gradient
            AppTheme.Gradients.cloud

            // Animated cloud layers
            Group {
                CloudShape()
                    .fill(.white.opacity(0.3))
                    .scaleEffect(animateCloud ? 1.1 : 1.0)
                    .offset(x: animateCloud ? 10 : -10, y: animateCloud ? -5 : 5)

                CloudShape()
                    .fill(.white.opacity(0.2))
                    .scaleEffect(animateCloud ? 1.0 : 1.1)
                    .offset(x: animateCloud ? -10 : 10, y: animateCloud ? 5 : -5)

                CloudShape()
                    .fill(.white.opacity(0.25))
                    .scaleEffect(animateCloud ? 1.05 : 0.95)
                    .offset(x: animateCloud ? 0 : 5, y: animateCloud ? -8 : 8)
            }
            .blur(radius: 40)

            // Optional album art overlay
            if let urlString = imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .opacity(0.6)
                        .blur(radius: 3)
                } placeholder: {
                    EmptyView()
                }
            }

            // Foreground cloud
            CloudShape()
                .fill(.white.opacity(0.4))
                .scaleEffect(0.4)
                .blur(radius: 20)
                .offset(y: animateCloud ? -20 : 20)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 8)
                .repeatForever(autoreverses: true)
            ) {
                animateCloud = true
            }
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Create a cloud-like shape using bezier curves
        path.move(to: CGPoint(x: width * 0.3, y: height * 0.5))

        // Bottom left bubble
        path.addEllipse(in: CGRect(
            x: width * 0.1,
            y: height * 0.4,
            width: width * 0.3,
            height: height * 0.3
        ))

        // Bottom right bubble
        path.addEllipse(in: CGRect(
            x: width * 0.6,
            y: height * 0.45,
            width: width * 0.3,
            height: height * 0.25
        ))

        // Top middle bubble
        path.addEllipse(in: CGRect(
            x: width * 0.35,
            y: height * 0.25,
            width: width * 0.35,
            height: height * 0.35
        ))

        // Center bubble
        path.addEllipse(in: CGRect(
            x: width * 0.25,
            y: height * 0.35,
            width: width * 0.5,
            height: height * 0.4
        ))

        return path
    }
}

// Simple placeholder cloud for small thumbnails
struct CloudPlaceholderView: View {
    var body: some View {
        ZStack {
            AppTheme.Gradients.cloud

            Image(systemName: "cloud.fill")
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.4))
        }
    }
}

#Preview("Animated Cloud") {
    AnimatedCloudView(imageURL: nil)
        .frame(width: 300, height: 300)
        .cornerRadius(20)
}

#Preview("Cloud Placeholder") {
    CloudPlaceholderView()
        .frame(width: 56, height: 56)
        .cornerRadius(8)
}
