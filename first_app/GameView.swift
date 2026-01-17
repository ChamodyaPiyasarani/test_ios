import SwiftUI

struct GameView: View {
    let mode: String

    let colors: [Color] = [.red, .blue, .green, .orange, .purple]

    @State private var targetColor: Color = .red
    @State private var squareColors: [Color] =
        Array(repeating: .gray, count: 9) // ✅ initialize safely

    let columns = Array(repeating: GridItem(.flexible()), count: 3)

    var body: some View {
        VStack(spacing: 25) {

            Text("Mode: \(mode)")
                .font(.headline)

            VStack {
                Text("Tap this color")
                    .font(.subheadline)

                RoundedRectangle(cornerRadius: 8)
                    .fill(targetColor)
                    .frame(width: 120, height: 40)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<9, id: \.self) { index in
                    Button {
                        squareTapped(index)
                    } label: {
                        Rectangle()
                            .fill(squareColors[index])
                            .frame(width: 90, height: 90)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .onAppear {
            resetGame()
        }
    }

    // MARK: - Game Logic

    func resetGame() {
        squareColors = (0..<9).map { _ in colors.randomElement()! }
        targetColor = squareColors.randomElement()!
    }

    func squareTapped(_ index: Int) {
        if squareColors[index] == targetColor {
            resetGame()
        }
    }
}

#Preview {
    GameView(mode: "Easy")
}
