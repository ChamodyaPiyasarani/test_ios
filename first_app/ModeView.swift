import SwiftUI

struct ModeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink("Easy") {
                    GameView(mode: "Easy")
                }

                NavigationLink("Medium") {
                    GameView(mode: "Medium")
                }

                NavigationLink("Hard") {
                    GameView(mode: "Hard")
                }
            }
            .font(.title2)
            .navigationTitle("Select Mode")
        }
    }
}

#Preview {
    ModeView()
}
