import SwiftUI

@main
struct ColorMemoryGameApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(authViewModel)
                .preferredColorScheme(authViewModel.colorScheme)
                .onAppear {
                    applyColorScheme()
                }
                .onChange(of: authViewModel.currentUser?.isDarkMode) { _ in
                    applyColorScheme()
                }
        }
    }
    
    private func applyColorScheme() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = authViewModel.currentUser?.isDarkMode == true ? .dark : .light
                }
            }
        }
    }
}
