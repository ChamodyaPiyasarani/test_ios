import SwiftUI

struct ModeView: View {
    @State private var showSettings = false
    @State private var highScores: [String: Int] = ["Easy": 0, "Medium": 0, "Hard": 0]
    @State private var soundEnabled = true
    @State private var hapticEnabled = true
    @State private var selectedMode: String? = nil
    
    let modes = [
        ModeInfo(title: "Easy",
                description: "4 Cards • Perfect for beginners",
                color: .green,
                icon: "leaf.fill",
                squareCount: 4,
                gradient: LinearGradient(
                    colors: [.green, .mint],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )),
        ModeInfo(title: "Medium",
                description: "8 Cards • Challenge yourself",
                color: .orange,
                icon: "flame.fill",
                squareCount: 8,
                gradient: LinearGradient(
                    colors: [.orange, .yellow],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )),
        ModeInfo(title: "Hard",
                description: "12 Cards • Expert level",
                color: .red,
                icon: "bolt.fill",
                squareCount: 12,
                gradient: LinearGradient(
                    colors: [.red, .purple],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
    ]
    
    struct ModeInfo {
        let title: String
        let description: String
        let color: Color
        let icon: String
        let squareCount: Int
        let gradient: LinearGradient
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background with animated gradient
                AnimatedBackground()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HeaderView()
                    
                    // Game Title
                    VStack(spacing: 10) {
                        Text("Memory Match")
                            .font(.system(size: 48, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                        
                        Text("Challenge Your Memory")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                            .fontWeight(.medium)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                    
                    // Mode Selection Cards
                    VStack(spacing: 25) {
                        ForEach(modes, id: \.title) { mode in
                            NavigationLink(destination: GameView(mode: mode.title, squareCount: mode.squareCount)) {
                                ModeCard(mode: mode, highScore: highScores[mode.title] ?? 0)
                            }
                            .buttonStyle(CustomButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Bottom Info
                    VStack(spacing: 15) {
                        HStack(spacing: 30) {
                            InfoBadge(icon: "trophy.fill",
                                     title: "High Score",
                                     value: "\(highScores.values.max() ?? 0)")
                            InfoBadge(icon: "clock.fill",
                                     title: "Time",
                                     value: "60s")
                        }
                        
                        Text("Select a difficulty to start playing")
                            .font(.callout)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.bottom, 10)
                    }
                    .padding(.bottom, 30)
                }
                
                // Settings Button
                VStack {
                    HStack {
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
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.trailing, 20)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSettings) {
                SettingsView(soundEnabled: $soundEnabled,
                            hapticEnabled: $hapticEnabled,
                            highScores: $highScores)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            // Load saved high scores
            loadHighScores()
        }
    }
    
    private func loadHighScores() {
        // In a real app, load from UserDefaults
        // For demo, using sample data
        highScores = ["Easy": 1250, "Medium": 980, "Hard": 750]
    }
}

// MARK: - Custom Components
struct AnimatedBackground: View {
    @State private var gradientOffset = CGSize.zero
    
    var body: some View {
        ZStack {
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
            
            // Animated floating shapes
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 300)
                .offset(x: 100, y: -200)
                .blur(radius: 60)
            
            Circle()
                .fill(Color.purple.opacity(0.1))
                .frame(width: 400)
                .offset(x: -150, y: 300)
                .blur(radius: 60)
        }
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 20).repeatForever(autoreverses: true)) {
                gradientOffset = CGSize(width: 50, height: 50)
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.9))
                .shadow(color: .blue, radius: 10)
            
            Text("Select Mode")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(.top, 50)
    }
}

struct ModeCard: View {
    let mode: ModeView.ModeInfo
    let highScore: Int
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(mode.color.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: mode.icon)
                    .font(.system(size: 30))
                    .foregroundColor(mode.color)
            }
            
            // Text Content
            VStack(alignment: .leading, spacing: 5) {
                Text(mode.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(mode.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                if highScore > 0 {
                    HStack(spacing: 5) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("High Score: \(highScore)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: mode.color.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .scaleEffect(isHovered ? 1.03 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
    }
}

struct CustomButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct InfoBadge: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .frame(width: 120)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Binding var soundEnabled: Bool
    @Binding var hapticEnabled: Bool
    @Binding var highScores: [String: Int]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemTeal).opacity(0.8),
                        Color(.systemIndigo).opacity(0.9),
                        Color(.systemPurple).opacity(0.7)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)
                            
                            Text("Settings")
                                .font(.system(size: 34, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Settings Cards
                        VStack(spacing: 15) {
                            // Sound Settings
                            SettingCard(
                                icon: "speaker.wave.2.fill",
                                title: "Sound Effects",
                                isEnabled: $soundEnabled,
                                color: .blue
                            )
                            
                            // Haptic Settings
                            SettingCard(
                                icon: "iphone.radiowaves.left.and.right",
                                title: "Haptic Feedback",
                                isEnabled: $hapticEnabled,
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                        
                        // High Scores Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("High Scores")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                ForEach(["Easy", "Medium", "Hard"], id: \.self) { mode in
                                    HighScoreRow(
                                        mode: mode,
                                        score: highScores[mode] ?? 0,
                                        color: mode == "Easy" ? .green : mode == "Medium" ? .orange : .red
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        
                        // Reset Button
                        Button(action: {
                            resetScores()
                        }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset High Scores")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.3))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func resetScores() {
        withAnimation {
            highScores = ["Easy": 0, "Medium": 0, "Hard": 0]
        }
    }
}

struct SettingCard: View {
    let icon: String
    let title: String
    @Binding var isEnabled: Bool
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .toggleStyle(SwitchToggleStyle(tint: color))
                .labelsHidden()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct HighScoreRow: View {
    let mode: String
    let score: Int
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(mode.prefix(1)))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    )
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(mode)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text("\(score) points")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            Image(systemName: "trophy.fill")
                .font(.title2)
                .foregroundColor(score > 0 ? .yellow : .gray.opacity(0.5))
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.05))
        )
    }
}

#Preview {
    ModeView()
}
