import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showGameView = false
    @State private var selectedMode: GameMode?
    @State private var showLeaderboard = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Text("Color Memory")
                            .font(.largeTitle)
                            .foregroundColor(.primary)
                            .bold()
                        
                        Spacer()
                        
                        if authViewModel.isLoggedIn {
                            Button(action: { showLeaderboard = true }) {
                                Image(systemName: "trophy")
                                    .foregroundColor(.primary)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding()
                    
                    if authViewModel.isLoggedIn, let user = authViewModel.currentUser {
                        // Welcome Message with High Scores
                        VStack {
                            Text("Welcome, \(user.username)!")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                            Text("High Scores")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.top, 5)
                            
                            // High Scores Display
                            HStack(spacing: 20) {
                                ForEach(GameMode.allCases, id: \.self) { mode in
                                    VStack {
                                        Text(mode.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text("\(getHighScore(for: mode, user: user))")
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .fontWeight(.bold)
                                    }
                                    .frame(width: 80)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                        
                        // Difficulty Selection
                        VStack(spacing: 20) {
                            ForEach(GameMode.allCases, id: \.self) { mode in
                                Button(action: {
                                    selectedMode = mode
                                    showGameView = true
                                }) {
                                    DifficultyButton(mode: mode)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // NavigationLink for GameView
                        NavigationLink(
                            destination: Group {
                                if let mode = selectedMode {
                                    GameView(mode: mode, user: user)
                                }
                            },
                            isActive: $showGameView
                        ) {
                            EmptyView()
                        }
                    } else {
                        // Login Prompt
                        VStack(spacing: 20) {
                            Text("Please login to play")
                                .font(.title2)
                                .foregroundColor(.primary)
                            
                            Button(action: { authViewModel.showLogin = true }) {
                                Text("Login / Register")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                    
                    // Settings Button
                    if authViewModel.isLoggedIn {
                        NavigationLink(destination: SettingsView().environmentObject(authViewModel)) {
                            Image(systemName: "gear")
                                .foregroundColor(.primary)
                                .font(.title2)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $authViewModel.showLogin) {
                LoginView(authViewModel: authViewModel)
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
        }
        .preferredColorScheme(authViewModel.colorScheme)
    }
    
    private func getHighScore(for mode: GameMode, user: User) -> Int {
        return user.highScores[mode.rawValue] ?? 0
    }
}

struct DifficultyButton: View {
    let mode: GameMode
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mode.rawValue)
                    .font(.title2)
                    .foregroundColor(.primary)
                Text(difficultyDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .foregroundColor(.primary)
                .font(.title2)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
    
    private var difficultyDescription: String {
        switch mode {
        case .easy: return "4 cards, 60 seconds"
        case .medium: return "6 cards, 45 seconds"
        case .hard: return "8 cards, 30 seconds, shapes"
        }
    }
}
