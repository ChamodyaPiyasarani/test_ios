import Foundation

class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    
    private enum Keys {
        static let currentUser = "currentUser"
        static let allUsers = "allUsers"
        // Removed savedGameState since we don't save game state
    }
    
    func saveCurrentUser(_ user: User?) {
        guard let user = user else {
            userDefaults.removeObject(forKey: Keys.currentUser)
            return
        }
        
        do {
            let encoded = try JSONEncoder().encode(user)
            userDefaults.set(encoded, forKey: Keys.currentUser)
        } catch {
            print("Error saving current user: \(error)")
        }
    }
    
    func getCurrentUser() -> User? {
        guard let data = userDefaults.data(forKey: Keys.currentUser) else {
            return nil
        }
        
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            print("Error loading current user: \(error)")
            return nil
        }
    }
    
    func saveUser(_ user: User) {
        var allUsers = getAllUsers()
        
        if let index = allUsers.firstIndex(where: { $0.id == user.id }) {
            allUsers[index] = user
        } else {
            allUsers.append(user)
        }
        
        do {
            let encoded = try JSONEncoder().encode(allUsers)
            userDefaults.set(encoded, forKey: Keys.allUsers)
        } catch {
            print("Error saving users: \(error)")
        }
    }
    
    func getAllUsers() -> [User] {
        guard let data = userDefaults.data(forKey: Keys.allUsers) else {
            return []
        }
        
        do {
            let users = try JSONDecoder().decode([User].self, from: data)
            return users
        } catch {
            print("Error loading users: \(error)")
            return []
        }
    }
    
    func updateHighScore(for user: User, mode: GameMode, score: Int) -> User {
        var updatedUser = user
        if score > updatedUser.highScore(for: mode) {
            updatedUser.setHighScore(score, for: mode)
            saveUser(updatedUser)
        }
        return updatedUser
    }
    
    func getLeaderboard() -> [User] {
        return getAllUsers()
            .sorted { ($0.highScore(for: .hard)) > ($1.highScore(for: .hard)) }
    }
}
