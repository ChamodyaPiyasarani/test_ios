import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var username: String
    var highScores: [String: Int] // Use String instead of GameMode as key
    var isDarkMode: Bool
    
    init(username: String) {
        self.id = UUID()
        self.username = username
        self.highScores = [
            "Easy": 0,
            "Medium": 0,
            "Hard": 0
        ]
        self.isDarkMode = false
    }
    
    // Helper methods to work with GameMode enum
    func highScore(for mode: GameMode) -> Int {
        return highScores[mode.rawValue] ?? 0
    }
    
    mutating func setHighScore(_ score: Int, for mode: GameMode) {
        highScores[mode.rawValue] = score
    }
}

enum GameMode: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var initialCards: Int {
        switch self {
        case .easy: return 4
        case .medium: return 6
        case .hard: return 8
        }
    }
    
    var timeLimit: TimeInterval {
        switch self {
        case .easy: return 60.0
        case .medium: return 45.0
        case .hard: return 30.0
        }
    }
    
    var levelIncreaseThreshold: Int {
        switch self {
        case .easy: return 3
        case .medium: return 5
        case .hard: return 7
        }
    }
}
