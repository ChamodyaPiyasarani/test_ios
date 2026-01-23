import SwiftUI

struct MainMenuView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var showGameView = false
    @State private var selectedMode: GameMode?
    @State private var showLeaderboard = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    HStack {
                        Text("Color Memory")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .bold()
                        
                        Spacer()
                        
                        if authViewModel.isLoggedIn {
                            Button(action: { showLeaderboard = true }) {
                                Image(systemName: "trophy")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding()
                    
                    if authViewModel.isLoggedIn, let user = authViewModel.currentUser {
                        // Welcome Message
                        VStack {
                            Text("Welcome, \(user.username)!")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("High Scores")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                            
                            HStack(spacing: 20) {
                                ForEach(GameMode.allCases, id: \.self) { mode in
                                    VStack {
                                        Text(mode.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text("\(user.highScore(for: mode))")
                                            .font(.title3)
                                            .foregroundColor(.white)
                                    }
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
                                .foregroundColor(.white)
                            
                            Button(action: { authViewModel.showLogin = true }) {
                                Text("Login / Register")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 40)
                        }
                    }
                    
                    Spacer()
                    
                    // Settings Button
                    if authViewModel.isLoggedIn {
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
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
        .preferredColorScheme(authViewModel.currentUser?.isDarkMode == true ? .dark : .light)
    }
}

struct DifficultyButton: View {
    let mode: GameMode
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(mode.rawValue)
                    .font(.title2)
                    .foregroundColor(.white)
                Text(difficultyDescription)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
                .foregroundColor(.white)
                .font(.title2)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
    
    private var difficultyDescription: String {
        switch mode {
        case .easy: return "4 cards, 60 seconds"
        case .medium: return "6 cards, 45 seconds"
        case .hard: return "8 cards, 30 seconds, shapes"
        }
    }
}
