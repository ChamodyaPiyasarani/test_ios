import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    @Published var isLoggedIn = false
    @Published var showLogin = false
    
    private let storageService = StorageService.shared
    
    init() {
        loadCurrentUser()
        loadUsers()
    }
    
    func loadCurrentUser() {
        currentUser = storageService.getCurrentUser()
        isLoggedIn = currentUser != nil
    }
    
    func loadUsers() {
        users = storageService.getAllUsers()
    }
    
    func login(username: String) {
        if let existingUser = users.first(where: { $0.username.lowercased() == username.lowercased() }) {
            currentUser = existingUser
        } else {
            let newUser = User(username: username)
            currentUser = newUser
            storageService.saveUser(newUser)
            loadUsers()
        }
        
        storageService.saveCurrentUser(currentUser)
        isLoggedIn = true
    }
    
    func logout() {
        storageService.saveCurrentUser(nil)
        currentUser = nil
        isLoggedIn = false
    }
    
    func toggleDarkMode() {
        guard var user = currentUser else { return }
        user.isDarkMode.toggle()
        currentUser = user
        storageService.saveUser(user)
        storageService.saveCurrentUser(user)
        
        // Post notification to update UI
        NotificationCenter.default.post(name: NSNotification.Name("UpdateColorScheme"), object: nil)
    }
}
