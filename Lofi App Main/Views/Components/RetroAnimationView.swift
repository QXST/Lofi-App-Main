import SwiftUI

enum RetroAnimationStyle: Int, CaseIterable {
    case coffeeShop
    case vinylPlayer
    case cassetteDeck
    case crtMonitor
    case bedroomStudy
    case boombox

    var name: String {
        switch self {
        case .coffeeShop: return "Coffee Shop"
        case .vinylPlayer: return "Vinyl Vibes"
        case .cassetteDeck: return "Cassette Deck"
        case .crtMonitor: return "Retro Monitor"
        case .bedroomStudy: return "Study Room"
        case .boombox: return "Boombox"
        }
    }
}

struct RetroAnimationView: View {
    @Binding var currentStyle: RetroAnimationStyle
    @State private var animationPhase: Double = 0
    @State private var showStyleName: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient based on style
                backgroundGradient
                    .ignoresSafeArea()

                // Animation content
                Group {
                    switch currentStyle {
                    case .coffeeShop:
                        CoffeeShopAnimation(phase: animationPhase)
                    case .vinylPlayer:
                        VinylPlayerAnimation(phase: animationPhase)
                    case .cassetteDeck:
                        CassetteDeckAnimation(phase: animationPhase)
                    case .crtMonitor:
                        CRTMonitorAnimation(phase: animationPhase)
                    case .bedroomStudy:
                        BedroomStudyAnimation(phase: animationPhase)
                    case .boombox:
                        BoomboxAnimation(phase: animationPhase)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Style name indicator (shows briefly when changed)
                if showStyleName {
                    VStack {
                        Spacer()
                        Text(currentStyle.name)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                            )
                            .padding(.bottom, 180)
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        handleSwipe(value: value)
                    }
            )
            .onAppear {
                startAnimation()
            }
        }
    }

    private var backgroundGradient: LinearGradient {
        switch currentStyle {
        case .coffeeShop:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.3, blue: 0.2), Color(red: 0.2, green: 0.15, blue: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vinylPlayer:
            return LinearGradient(
                colors: [Color(red: 0.3, green: 0.2, blue: 0.3), Color(red: 0.15, green: 0.1, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .cassetteDeck:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.4), Color(red: 0.1, green: 0.15, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .crtMonitor:
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.15, blue: 0.2), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
        case .bedroomStudy:
            return LinearGradient(
                colors: [Color(red: 0.25, green: 0.3, blue: 0.4), Color(red: 0.15, green: 0.2, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .boombox:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.2, blue: 0.3), Color(red: 0.2, green: 0.1, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            animationPhase = 1
        }
    }

    private func handleSwipe(value: DragGesture.Value) {
        if value.translation.width > 0 {
            // Swipe right - previous style
            previousStyle()
        } else if value.translation.width < 0 {
            // Swipe left - next style
            nextStyle()
        }
    }

    private func nextStyle() {
        let currentIndex = RetroAnimationStyle.allCases.firstIndex(of: currentStyle) ?? 0
        let nextIndex = (currentIndex + 1) % RetroAnimationStyle.allCases.count

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentStyle = RetroAnimationStyle.allCases[nextIndex]
        }

        showStyleNameBriefly()
    }

    private func previousStyle() {
        let currentIndex = RetroAnimationStyle.allCases.firstIndex(of: currentStyle) ?? 0
        let previousIndex = (currentIndex - 1 + RetroAnimationStyle.allCases.count) % RetroAnimationStyle.allCases.count

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            currentStyle = RetroAnimationStyle.allCases[previousIndex]
        }

        showStyleNameBriefly()
    }

    private func showStyleNameBriefly() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showStyleName = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                showStyleName = false
            }
        }
    }
}

// MARK: - Coffee Shop Animation
struct CoffeeShopAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Coffee cup with steam
            VStack(spacing: 40) {
                // Steam
                HStack(spacing: 20) {
                    ForEach(0..<3) { index in
                        SteamPuff(delay: Double(index) * 0.3, phase: phase)
                    }
                }
                .offset(y: -20)

                // Coffee cup
                CoffeeCup()
                    .frame(width: 120, height: 140)
            }

            // Floating pixel particles
            ForEach(0..<8) { index in
                PixelParticle(index: index, phase: phase)
            }
        }
    }
}

struct SteamPuff: View {
    let delay: Double
    let phase: Double

    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.3))
            .frame(width: 15, height: 15)
            .offset(y: -20 * sin((phase + delay) * .pi * 2))
            .opacity(0.7 - 0.7 * sin((phase + delay) * .pi * 2))
            .blur(radius: 3)
    }
}

struct CoffeeCup: View {
    var body: some View {
        ZStack {
            // Cup body
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.9))
                .frame(width: 80, height: 100)

            // Coffee inside
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 0.4, green: 0.25, blue: 0.15))
                .frame(width: 70, height: 60)
                .offset(y: -15)

            // Cup handle
            Circle()
                .stroke(Color.white.opacity(0.9), lineWidth: 8)
                .frame(width: 30, height: 40)
                .offset(x: 50, y: 0)
        }
    }
}

// MARK: - Vinyl Player Animation
struct VinylPlayerAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Vinyl record
            Circle()
                .fill(Color.black)
                .frame(width: 200, height: 200)
                .overlay(
                    Circle()
                        .fill(Color(red: 0.3, green: 0.1, blue: 0.1))
                        .frame(width: 60, height: 60)
                )
                .overlay(
                    ForEach(0..<5) { index in
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            .frame(width: 200 - CGFloat(index * 30), height: 200 - CGFloat(index * 30))
                    }
                )
                .rotationEffect(.degrees(phase * 360 * 2))

            // Tonearm
            VinylTonearm(phase: phase)
                .offset(x: 80, y: -40)

            // Floating musical notes
            ForEach(0..<4) { index in
                MusicalNote(index: index, phase: phase)
            }
        }
    }
}

struct VinylTonearm: View {
    let phase: Double

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Arm
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.8))
                .frame(width: 80, height: 8)
                .rotationEffect(.degrees(-45))

            // Needle
            Circle()
                .fill(Color.orange)
                .frame(width: 12, height: 12)
                .offset(x: -70, y: 50)
        }
    }
}

struct MusicalNote: View {
    let index: Int
    let phase: Double

    var body: some View {
        let angle = Double(index) * .pi / 2 + phase * .pi * 2
        let xOffset = 100 * cos(angle)
        let yOffset = 100 * sin(angle)
        let opacityValue = 0.7 - 0.3 * sin(phase * .pi * 2)

        return Text(["♪", "♫", "♬", "♩"][index])
            .font(.system(size: 24))
            .foregroundColor(.white.opacity(0.6))
            .offset(x: xOffset, y: yOffset)
            .opacity(opacityValue)
    }
}

// MARK: - Cassette Deck Animation
struct CassetteDeckAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Cassette body
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.9, green: 0.85, blue: 0.7))
                .frame(width: 240, height: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.black.opacity(0.3), lineWidth: 2)
                )

            // Transparent window
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.3))
                .frame(width: 200, height: 80)
                .offset(y: -20)

            // Reels
            HStack(spacing: 100) {
                CassetteReel(phase: phase)
                CassetteReel(phase: phase)
            }
            .offset(y: -20)

            // Label
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.8))
                .frame(width: 180, height: 40)
                .overlay(
                    VStack(spacing: 4) {
                        Text("LOFI MIX")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                        Text("Side A")
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(.black)
                )
                .offset(y: 45)
        }
    }
}

struct CassetteReel: View {
    let phase: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.7))
                .frame(width: 50, height: 50)

            ForEach(0..<6) { index in
                Rectangle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 2, height: 20)
                    .offset(y: -15)
                    .rotationEffect(.degrees(Double(index) * 60 + phase * 360))
            }

            Circle()
                .fill(Color.gray)
                .frame(width: 15, height: 15)
        }
    }
}

// MARK: - CRT Monitor Animation
struct CRTMonitorAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Monitor frame
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 300, height: 240)

            // Screen
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.05, green: 0.1, blue: 0.08))
                .frame(width: 270, height: 200)
                .overlay(
                    // Scanlines
                    VStack(spacing: 4) {
                        ForEach(0..<20) { _ in
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 1)
                        }
                    }
                )
                .overlay(
                    // Waveform
                    WaveformView(phase: phase)
                        .stroke(Color.green, lineWidth: 2)
                        .padding(20)
                )

            // Screen glare
            LinearGradient(
                colors: [Color.white.opacity(0.2), Color.clear],
                startPoint: .topLeading,
                endPoint: .center
            )
            .frame(width: 270, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

struct WaveformView: Shape {
    let phase: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let amplitude: CGFloat = 40
        let frequency: CGFloat = 4

        path.move(to: CGPoint(x: 0, y: rect.midY))

        for x in stride(from: 0, through: rect.width, by: 2) {
            let relativeX = x / rect.width
            let sine = sin((relativeX * frequency + phase) * .pi * 2)
            let y = rect.midY + amplitude * CGFloat(sine)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

// MARK: - Bedroom Study Animation
struct BedroomStudyAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Window with moon
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.1, green: 0.15, blue: 0.3))
                .frame(width: 150, height: 200)
                .overlay(
                    VStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: 50, height: 50)
                            .offset(y: 20)
                        Spacer()
                    }
                )
                .offset(y: -80)

            // Desk lamp
            DeskLamp(phase: phase)
                .offset(x: -80, y: 40)

            // Books stack
            VStack(spacing: 0) {
                ForEach(0..<4) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(hue: Double(index) * 0.15, saturation: 0.6, brightness: 0.7))
                        .frame(width: 80 - CGFloat(index * 5), height: 15)
                        .rotationEffect(.degrees(Double(index) * -2))
                }
            }
            .offset(x: 70, y: 80)

            // Floating stars/sparkles
            ForEach(0..<6) { index in
                Star(index: index, phase: phase)
            }
        }
    }
}

struct DeskLamp: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Lamp shade
            Path { path in
                path.move(to: CGPoint(x: 30, y: 0))
                path.addLine(to: CGPoint(x: 60, y: 40))
                path.addLine(to: CGPoint(x: 0, y: 40))
                path.closeSubpath()
            }
            .fill(Color.orange.opacity(0.7))

            // Light beam
            Path { path in
                path.move(to: CGPoint(x: 30, y: 40))
                path.addLine(to: CGPoint(x: 70, y: 100))
                path.addLine(to: CGPoint(x: -10, y: 100))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .opacity(0.7 + 0.3 * sin(phase * .pi * 2))

            // Stand
            Rectangle()
                .fill(Color.gray)
                .frame(width: 4, height: 60)
                .offset(y: 60)
        }
    }
}

struct Star: View {
    let index: Int
    let phase: Double

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 12))
            .foregroundColor(.yellow.opacity(0.7))
            .offset(
                x: 120 * cos(Double(index) * .pi / 3 + phase * .pi * 2),
                y: 120 * sin(Double(index) * .pi / 3 + phase * .pi * 2) - 50
            )
            .opacity(0.5 + 0.5 * sin(phase * .pi * 2 + Double(index)))
    }
}

// MARK: - Boombox Animation
struct BoomboxAnimation: View {
    let phase: Double

    var body: some View {
        ZStack {
            // Boombox body
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.8))
                .frame(width: 280, height: 160)

            // Speakers
            HStack(spacing: 80) {
                Speaker(phase: phase)
                Speaker(phase: phase)
            }

            // Cassette deck in center
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.6))
                .frame(width: 80, height: 50)
                .overlay(
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 15, height: 15)
                            .rotationEffect(.degrees(phase * 360))
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 15, height: 15)
                            .rotationEffect(.degrees(phase * 360))
                    }
                )

            // Handle
            Capsule()
                .stroke(Color.gray.opacity(0.9), lineWidth: 8)
                .frame(width: 120, height: 40)
                .offset(y: -100)

            // Sound waves
            ForEach(0..<3) { index in
                SoundWave(index: index, phase: phase)
            }
        }
    }
}

struct Speaker: View {
    let phase: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.7))
                .frame(width: 70, height: 70)

            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    .frame(width: 70 - CGFloat(index * 20), height: 70 - CGFloat(index * 20))
                    .scaleEffect(1 + 0.1 * sin(phase * .pi * 4 + Double(index)))
            }
        }
    }
}

struct SoundWave: View {
    let index: Int
    let phase: Double

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.white.opacity(0.3))
            .frame(width: 3, height: 20 + 10 * sin(phase * .pi * 4 + Double(index)))
            .offset(x: 160 + CGFloat(index * 15))
            .opacity(0.7 - 0.3 * sin(phase * .pi * 2))
    }
}

// MARK: - Pixel Particle (used in coffee shop)
struct PixelParticle: View {
    let index: Int
    let phase: Double

    var body: some View {
        let angle = Double(index) * .pi / 4 + phase * .pi * 2
        let xOffset = 150 * cos(angle)
        let yOffset = 150 * sin(angle)
        let opacityValue = 0.5 + 0.5 * sin(phase * .pi * 2 + Double(index))

        return Rectangle()
            .fill(Color.white.opacity(0.6))
            .frame(width: 4, height: 4)
            .offset(x: xOffset, y: yOffset)
            .opacity(opacityValue)
    }
}
