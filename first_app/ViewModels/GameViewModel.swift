import Foundation
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState: GameState
    @Published var currentUser: User?
    private var timer: Timer?
    private let storageService = StorageService.shared
    
    init(mode: GameMode, user: User?) {
        self.gameState = GameState(mode: mode)
        self.currentUser = user
        startTimer()
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.gameState.isPaused, !self.gameState.isGameOver else { return }
            
            self.gameState.timeRemaining -= 1
            if self.gameState.timeRemaining <= 0 {
                self.endGame()
            }
        }
    }
    
    func flipCard(_ card: GameCard) {
        guard !card.isMatched,
              !card.isFaceUp,
              gameState.flippedCards.count < 2,
              !gameState.isGameOver else { return }
        
        if let index = gameState.cards.firstIndex(where: { $0.id == card.id }) {
            gameState.cards[index].isFaceUp = true
            gameState.cards[index].wasFlipped = true
            gameState.flippedCards.append(card.id)
            
            if gameState.flippedCards.count == 2 {
                checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        let flippedIndices = gameState.cards.indices.filter { gameState.flippedCards.contains(gameState.cards[$0].id) }
        
        guard flippedIndices.count == 2 else { return }
        
        let card1 = gameState.cards[flippedIndices[0]]
        let card2 = gameState.cards[flippedIndices[1]]
        
        let isMatch: Bool
        if gameState.mode == .hard {
            isMatch = card1.shape == card2.shape
        } else {
            isMatch = card1.color == card2.color
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if isMatch {
                for index in flippedIndices {
                    self.gameState.cards[index].isMatched = true
                }
                self.gameState.score += 10 * self.gameState.level
                
                if self.allCardsMatched {
                    self.advanceLevel()
                }
            } else {
                for index in flippedIndices {
                    self.gameState.cards[index].isFaceUp = false
                }
            }
            
            self.gameState.flippedCards.removeAll()
        }
    }
    
    private var allCardsMatched: Bool {
        gameState.cards.allSatisfy { $0.isMatched }
    }
    
    private func advanceLevel() {
        gameState.level += 1
        gameState.timeRemaining = gameState.mode.timeLimit
        
        if gameState.level % gameState.mode.levelIncreaseThreshold == 0 {
            gameState.timeRemaining -= 5
        }
        
        gameState.cards = GameManager.generateCards(for: gameState.mode, level: gameState.level)
    }
    
    func pauseGame() {
        gameState.isPaused = true
        timer?.invalidate()
    }
    
    func resumeGame() {
        gameState.isPaused = false
        startTimer()
    }
    
    func endGame() {
        gameState.isGameOver = true
        timer?.invalidate()
        
        if let user = currentUser {
            currentUser = storageService.updateHighScore(for: user, mode: gameState.mode, score: gameState.score)
        }
    }
    
    func restartGame() {
        gameState = GameState(mode: gameState.mode)
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
}
