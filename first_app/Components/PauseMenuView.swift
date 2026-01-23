import SwiftUI

struct PauseMenuView: View {
    let onResume: () -> Void
    let onRestart: () -> Void
    let onExit: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    Button(action: onResume) {
                        Text("Resume")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: onRestart) {
                        Text("Restart")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.3))
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
