import Foundation

// GameState is NOT Codable - it's only for runtime game state
struct GameState {
    var score: Int
    var level: Int
    var timeRemaining: TimeInterval
    var cards: [GameCard]
    var mode: GameMode
    var flippedCards: [UUID]
    var isGameOver: Bool
    var isPaused: Bool
    
    init(mode: GameMode) {
        self.score = 0
        self.level = 1
        self.timeRemaining = mode.timeLimit
        self.mode = mode
        self.flippedCards = []
        self.isGameOver = false
        self.isPaused = false
        self.cards = GameManager.generateCards(for: mode, level: 1)
    }
}
