import Foundation

struct GameCard: Identifiable {
    let id = UUID()
    var color: String
    var shape: String?
    var isFaceUp: Bool = false
    var isMatched: Bool = false
    var wasFlipped: Bool = false
    
    static let colors = ["FF6B6B", "4ECDC4", "FFD166", "06D6A0", "118AB2", "EF476F"]
    static let shapes = ["circle", "square", "triangle", "diamond", "star", "heart"]
}
