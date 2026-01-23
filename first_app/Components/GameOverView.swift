import SwiftUI

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
