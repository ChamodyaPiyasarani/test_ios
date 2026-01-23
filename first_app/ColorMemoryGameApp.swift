import SwiftUI

@main
struct ColorMemoryGameApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environmentObject(authViewModel)
                .onAppear {
                    // Set initial color scheme
                    updateColorScheme()
                }
                .onChange(of: authViewModel.currentUser?.isDarkMode) { _ in
                    updateColorScheme()
                }
        }
    }
    
    private func updateColorScheme() {
        // This ensures the color scheme updates throughout the app
        UIApplication.shared.windows.first?.overrideUserInterfaceStyle =
            authViewModel.currentUser?.isDarkMode == true ? .dark : .light
    }
}
