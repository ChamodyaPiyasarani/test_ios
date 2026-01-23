import Foundation
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var isLoggedIn = false
    @Published var showLogin = false
    @Published var colorScheme: ColorScheme = .light
    
    private let storageService = StorageService.shared
    
    init() {
        loadCurrentUser()
        loadUsers()
        updateColorScheme()
    }
    
    func loadCurrentUser() {
        currentUser = storageService.getCurrentUser()
        isLoggedIn = currentUser != nil
        updateColorScheme()
    }
    
    func loadUsers() {
        users = storageService.getAllUsers()
    }
    
    func login(username: String) {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let existingUser = users.first(where: {
            $0.username.lowercased() == trimmedUsername.lowercased()
        }) {
            currentUser = existingUser
        } else {
            let newUser = User(username: trimmedUsername)
            currentUser = newUser
            storageService.saveUser(newUser)
            loadUsers()
        }
        
        storageService.saveCurrentUser(currentUser)
        isLoggedIn = true
        updateColorScheme()
        
        // Debug print
        print("User logged in: \(currentUser?.username ?? "Unknown")")
        print("High Scores: \(currentUser?.highScores ?? [:])")
    }
    
    func logout() {
        storageService.saveCurrentUser(nil)
        currentUser = nil
        isLoggedIn = false
        updateColorScheme()
    }
    
    func toggleDarkMode() {
        guard var user = currentUser else { return }
        user.isDarkMode.toggle()
        currentUser = user
        storageService.saveUser(user)
        storageService.saveCurrentUser(user)
        updateColorScheme()
    }
    
    func updateHighScore(for mode: GameMode, score: Int) {
        guard var user = currentUser else { return }
        
        let currentHighScore = user.highScores[mode.rawValue] ?? 0
        if score > currentHighScore {
            user.highScores[mode.rawValue] = score
            currentUser = user
            storageService.saveUser(user)
            storageService.saveCurrentUser(user)
            
            print("New high score for \(mode.rawValue): \(score)")
        }
    }
    
    private func updateColorScheme() {
        colorScheme = currentUser?.isDarkMode == true ? .dark : .light
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                for window in windowScene.windows {
                    window.overrideUserInterfaceStyle = self.currentUser?.isDarkMode == true ? .dark : .light
                }
            }
        }
    }
}
