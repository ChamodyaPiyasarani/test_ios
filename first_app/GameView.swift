import SwiftUI
import Combine

struct GameView: View {
    let mode: String
    let squareCount: Int

    // Color pool
    let baseColors: [Color] = [.red, .blue, .green, .orange, .purple, .yellow, .pink, .cyan, .mint, .indigo]

    // Game state
    @State private var squareColors: [Color] = []
    @State private var revealed: [Bool] = []
    @State private var matched: [Bool] = []
    @State private var firstIndex: Int? = nil
    @State private var attempts: Int = 0
    @State private var matchedPairs: Int = 0
    @State private var showConfetti: Bool = false
    @State private var gameCompleted: Bool = false
    @State private var score: Int = 1000
    @State private var timerValue: Int = 60
    @State private var timer: AnyCancellable?
    @State private var selectedIndices: [Int] = []
    
    // Settings
    @State private var cardStyle: CardStyle = .gradient
    @State private var showSettings: Bool = false
    
    enum CardStyle: String, CaseIterable {
        case gradient, flat, neon, glass
    }

    var columns: [GridItem] {
        let colCount = squareCount <= 4 ? 2 : squareCount <= 9 ? 3 : 4
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: colCount)
    }

    var body: some View {
        ZStack {
            // Enhanced background with depth
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemTeal).opacity(0.8),
                    Color(.systemIndigo).opacity(0.9),
                    Color(.systemPurple).opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .overlay(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 300
                )
            )
            .ignoresSafeArea()
            
            // Floating particles
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }

            VStack(spacing: 25) {
                // Modern Header with stats
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Memory Match")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 1, y: 1)
                            
                            Text("Mode: \(mode)")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                        .background(
                                            Capsule()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                showSettings.toggle()
                            }
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.2))
                                        .shadow(color: .black.opacity(0.2), radius: 5)
                                )
                        }
                    }
                    
                    // Stats Bar
                    HStack(spacing: 20) {
                        StatBadge(icon: "clock.fill", value: "\(timerValue)s", color: .blue)
                        StatBadge(icon: "target", value: "\(attempts)", color: .orange)
                        StatBadge(icon: "checkmark.circle.fill", value: "\(matchedPairs)/\(squareCount/2)", color: .green)
                        StatBadge(icon: "star.fill", value: "\(score)", color: .yellow)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Game Grid
                if squareColors.count == squareCount {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(0..<squareCount, id: \.self) { index in
                            AdvancedCardView(
                                color: squareColors[index],
                                isRevealed: revealed[index] || matched[index],
                                isMatched: matched[index],
                                isSelected: selectedIndices.contains(index),
                                style: cardStyle
                            )
                            .onTapGesture {
                                squareTapped(index)
                            }
                            .disabled(matched[index])
                            .rotation3DEffect(
                                .degrees(matched[index] ? 360 : 0),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.7)
                                .delay(Double(index % 10) * 0.05),
                                value: matched[index]
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }

                Spacer()
                
                // Control Panel
                VStack(spacing: 15) {
                    Button(action: resetGame) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("New Game")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .shadow(color: .blue.opacity(0.4), radius: 10, y: 5)
                        )
                    }
                    
                    // Style Picker
                    HStack {
                        ForEach(CardStyle.allCases, id: \.self) { style in
                            Button(action: {
                                withAnimation {
                                    cardStyle = style
                                }
                            }) {
                                Text(style.rawValue.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(cardStyle == style ? Color.white : Color.white.opacity(0.2))
                                    )
                                    .foregroundColor(cardStyle == style ? .blue : .white)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
            }
            
            // Settings Panel
            if showSettings {
                SettingsOverlay(isShowing: $showSettings)
                    .transition(.move(edge: .trailing))
            }
            
            // Completion Overlay
            if gameCompleted {
                CompletionOverlay(
                    score: score,
                    attempts: attempts,
                    time: 60 - timerValue,
                    onPlayAgain: resetGame
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            setupGame()
        }
        .onDisappear {
            // Clean up timer when view disappears
            stopTimer()
        }
        .onChange(of: matchedPairs) { newValue in
            if newValue == squareCount / 2 {
                withAnimation {
                    gameCompleted = true
                    showConfetti = true
                    score += timerValue * 10
                }
                stopTimer()
            }
        }
    }

    // MARK: - Timer Management
    private func startTimer() {
        // Cancel existing timer if any
        stopTimer()
        
        // Start new timer
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                if timerValue > 0 && !gameCompleted {
                    timerValue -= 1
                    if timerValue <= 10 {
                        score -= 10
                    }
                } else if timerValue == 0 && !gameCompleted {
                    gameCompleted = true
                    stopTimer()
                }
            }
    }
    
    private func stopTimer() {
        timer?.cancel()
        timer = nil
    }
    
    // MARK: - Setup Game
    func setupGame() {
        let pairs = squareCount / 2
        guard pairs <= baseColors.count else {
            fatalError("Not enough colors for this mode")
        }

        var colorsForGame = Array(baseColors.shuffled().prefix(pairs))
        colorsForGame += colorsForGame
        colorsForGame.shuffle()

        squareColors = colorsForGame
        revealed = Array(repeating: false, count: squareCount)
        matched = Array(repeating: false, count: squareCount)
        firstIndex = nil
        attempts = 0
        matchedPairs = 0
        gameCompleted = false
        showConfetti = false
        score = 1000
        timerValue = 60
        selectedIndices = []
        
        // Start the timer
        startTimer()
    }

    // MARK: - Game Logic
    func squareTapped(_ index: Int) {
        guard index < squareCount else { return }
        guard !revealed[index] && !matched[index] else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            revealed[index] = true
            selectedIndices.append(index)
        }

        if let first = firstIndex {
            attempts += 1
            score -= 5 // Small penalty for wrong attempts
            
            if squareColors[first] == squareColors[index] {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    matched[first] = true
                    matched[index] = true
                    matchedPairs += 1
                    score += 50 // Bonus for match
                }
                
                // Clear selection after match
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        selectedIndices.removeAll { $0 == first || $0 == index }
                    }
                }
            } else {
                // Flip back after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        revealed[first] = false
                        revealed[index] = false
                        selectedIndices.removeAll { $0 == first || $0 == index }
                    }
                }
            }
            firstIndex = nil
        } else {
            firstIndex = index
        }
    }
    
    func resetGame() {
        withAnimation(.spring()) {
            showConfetti = false
            gameCompleted = false
        }
        stopTimer()
        setupGame()
    }
}

// MARK: - Advanced Card View
struct AdvancedCardView: View {
    let color: Color
    let isRevealed: Bool
    let isMatched: Bool
    let isSelected: Bool
    let style: GameView.CardStyle
    
    var body: some View {
        ZStack {
            // Background card with style
            Group {
                switch style {
                case .gradient:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: isRevealed ? [color, color.opacity(0.8)] : [Color.gray.opacity(0.3), Color.gray.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                case .flat:
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isRevealed ? color : Color.gray.opacity(0.2))
                case .neon:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isRevealed ? color : Color.black.opacity(0.3))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isRevealed ? color : Color.white.opacity(0.2), lineWidth: 2)
                                .shadow(color: isRevealed ? color : .clear, radius: isRevealed ? 10 : 0)
                        )
                case .glass:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isRevealed ? color.opacity(0.9) : Color.white.opacity(0.1))
                        .background(
                            Color.white.opacity(0.1)
                                .blur(radius: 10)
                        )
                }
            }
            .frame(height: 100)
            .overlay(
                RoundedRectangle(cornerRadius: style == .flat ? 15 : 20)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.1), lineWidth: isSelected ? 3 : 1)
            )
            .shadow(
                color: isRevealed ? color.opacity(0.4) : .black.opacity(0.2),
                radius: isRevealed ? 10 : 5,
                x: 0,
                y: isRevealed ? 5 : 2
            )
            
            // Card content
            if isRevealed {
                if isMatched {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2)
                }
            } else {
                Image(systemName: "questionmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .rotationEffect(.degrees(isRevealed ? 0 : 180))
        .animation(
            .spring(response: 0.4, dampingFraction: 0.7),
            value: isRevealed
        )
        .rotation3DEffect(
            .degrees(isRevealed ? 0 : 180),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.15))
                .background(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .foregroundColor(.white)
    }
}

// MARK: - Confetti View (Simplified)
struct ConfettiView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var rotation: Double
        var scale: CGFloat
    }
    
    init() {
        // Create initial particles
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        for _ in 0..<50 {
            particles.append(Particle(
                x: CGFloat.random(in: 0...400),
                y: -20,
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.2)
            ))
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Rectangle()
                    .fill(particle.color)
                    .frame(width: 8, height: 8)
                    .rotationEffect(.degrees(particle.rotation))
                    .scaleEffect(particle.scale)
                    .position(x: particle.x, y: particle.y)
                    .onAppear {
                        withAnimation(
                            Animation.linear(duration: Double.random(in: 2...4))
                                .repeatForever(autoreverses: false)
                        ) {
                            // Update the particle's y position
                            // We need to use a local copy since we can't modify @State directly
                            let newY = CGFloat.random(in: 800...1200)
                            let newRotation = particle.rotation + Double.random(in: 180...720)
                            
                            // We'll use a DispatchQueue to update after animation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                if let index = particles.firstIndex(where: { $0.id == particle.id }) {
                                    particles[index].y = newY
                                    particles[index].rotation = newRotation
                                }
                            }
                        }
                    }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Settings Overlay
struct SettingsOverlay: View {
    @Binding var isShowing: Bool
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true
    @State private var difficulty = "Medium"
    
    let difficulties = ["Easy", "Medium", "Hard"]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            VStack(alignment: .leading, spacing: 25) {
                HStack {
                    Text("Settings")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    ToggleSetting(
                        isOn: $soundEnabled,
                        icon: "speaker.wave.2.fill",
                        title: "Sound Effects",
                        color: .blue
                    )
                    
                    ToggleSetting(
                        isOn: $vibrationEnabled,
                        icon: "iphone.radiowaves.left.and.right",
                        title: "Vibration",
                        color: .green
                    )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.orange)
                            Text("Difficulty")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(difficulties, id: \.self) { level in
                                Text(level).tag(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal, 8)
                }
                
                Spacer()
                
                Button(action: {
                    // Reset all settings
                    soundEnabled = true
                    vibrationEnabled = true
                    difficulty = "Medium"
                }) {
                    Text("Reset to Default")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.2))
                        )
                }
            }
            .padding(25)
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
            .padding(.trailing)
        }
    }
}

struct ToggleSetting: View {
    @Binding var isOn: Bool
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .labelsHidden()
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Completion Overlay
struct CompletionOverlay: View {
    let score: Int
    let attempts: Int
    let time: Int
    let onPlayAgain: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 70))
                    .foregroundColor(.yellow)
                    .shadow(color: .orange, radius: 10)
                
                Text("Level Complete!")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    StatRow(icon: "star.fill", label: "Score", value: "\(score)")
                    StatRow(icon: "target", label: "Attempts", value: "\(attempts)")
                    StatRow(icon: "clock.fill", label: "Time", value: "\(time)s")
                }
                .padding(.vertical)
                
                Button(action: onPlayAgain) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Play Again")
                    }
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background(
                        Capsule()
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .shadow(color: .blue.opacity(0.5), radius: 20)
                    )
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .padding(30)
        }
    }
}

struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.white)
                Text(label)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
            
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
}

#Preview {
    GameView(mode: "Easy", squareCount: 8)
}
