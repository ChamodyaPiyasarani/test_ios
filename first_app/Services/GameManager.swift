import Foundation

class GameManager {
    static func generateCards(for mode: GameMode, level: Int) -> [GameCard] {
        var cards: [GameCard] = []
        
        let pairsNeeded = mode.initialCards + (level - 1)
        
        if mode == .hard {
            // For hard mode, use shapes
            let availableShapes = GameCard.shapes.shuffled()
            let selectedShapes = Array(availableShapes.prefix(pairsNeeded))
            
            for shape in selectedShapes {
                let card1 = GameCard(color: GameCard.colors.randomElement()!, shape: shape)
                let card2 = GameCard(color: GameCard.colors.randomElement()!, shape: shape)
                cards.append(contentsOf: [card1, card2])
            }
        } else {
            // For easy and medium modes, use colors
            let availableColors = GameCard.colors.shuffled()
            let selectedColors = Array(availableColors.prefix(pairsNeeded))
            
            for color in selectedColors {
                let card1 = GameCard(color: color, shape: nil)
                let card2 = GameCard(color: color, shape: nil)
                cards.append(contentsOf: [card1, card2])
            }
        }
        
        return cards.shuffled()
    }
}
