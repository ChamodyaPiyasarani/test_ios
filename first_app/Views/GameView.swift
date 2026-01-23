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
// REMOVE GameOverView and PauseMenuView structs from here
