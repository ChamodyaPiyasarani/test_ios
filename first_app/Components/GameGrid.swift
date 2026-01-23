import SwiftUI

struct GameGrid: View {
    let cards: [GameCard]
    let mode: GameMode
    let columns: [GridItem]
    let onCardTap: (GameCard) -> Void
    
    init(cards: [GameCard], mode: GameMode, onCardTap: @escaping (GameCard) -> Void) {
        self.cards = cards
        self.mode = mode
        self.onCardTap = onCardTap
        
        let gridCount = Int(ceil(Double(cards.count) / 2.0))
        self.columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: gridCount)
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(cards) { card in
                CardView(card: card, mode: mode) {
                    onCardTap(card)
                }
                .aspectRatio(2/3, contentMode: .fit)
            }
        }
        .padding()
    }
}
