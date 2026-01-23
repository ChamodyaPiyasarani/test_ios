import SwiftUI

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showPauseMenu = false
    
    init(mode: GameMode, user: User?) {
        _viewModel = StateObject(wrappedValue: GameViewModel(mode: mode, user: user))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("Level \(viewModel.gameState.level)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Score: \(viewModel.gameState.score)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { showPauseMenu = true }) {
                        Image(systemName: "pause.circle")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                }
                .padding()
                
                // Timer
                Text(timeString)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundColor(timerColor)
                    .padding()
                
                // Game Grid
                GameGrid(
                    cards: viewModel.gameState.cards,
                    mode: viewModel.gameState.mode
                ) { card in
                    viewModel.flipCard(card)
                }
                
                Spacer()
            }
            
            // Game Over Overlay
            if viewModel.gameState.isGameOver {
                GameOverView(
                    score: viewModel.gameState.score,
                    onRestart: viewModel.restartGame,
                    onExit: { presentationMode.wrappedValue.dismiss() }
                )
            }
            
            // Pause Menu
            if showPauseMenu {
                PauseMenuView(
                    onResume: {
                        showPauseMenu = false
                        viewModel.resumeGame()
                    },
                    onRestart: {
                        showPauseMenu = false
                        viewModel.restartGame()
                    },
                    onExit: { presentationMode.wrappedValue.dismiss() }
                )
            }
        }
        .navigationBarHidden(true)
    }
    
    private var timeString: String {
        let minutes = Int(viewModel.gameState.timeRemaining) / 60
        let seconds = Int(viewModel.gameState.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var timerColor: Color {
        viewModel.gameState.timeRemaining < 10 ? .red : .white
    }
}

struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Game Over")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("Final Score: \(score)")
                    .font(.title)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Button(action: onRestart) {
                        Text("Play Again")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: onExit) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(40)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Button(action: onResume) {
                        Text("Resume")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: onRestart) {
                        Text("Restart")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                    
                    Button(action: onExit) {
                        Text("Exit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(40)
            .background(Color.black.opacity(0.9))
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}
