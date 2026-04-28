import Foundation
import SwiftData
import CryptoKit

@Observable
final class AuthService {
    private var modelContext: ModelContext?
    
    var currentUser: User?
    var isAuthenticated: Bool = false
    var errorMessage: String?
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        checkExistingSession()
    }
    
    func register(username: String, password: String, birthdate: Date) -> Bool {
        guard let context = modelContext else {
            errorMessage = "Database not available"
            return false
        }
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Username is required"
            return false
        }
        
        guard password.count >= 4 else {
            errorMessage = "Password must be at least 4 characters"
            return false
        }
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        do {
            let existing = try context.fetch(descriptor)
            guard existing.isEmpty else {
                errorMessage = "Username already exists"
                return false
            }
        } catch {
            errorMessage = "Database error"
            return false
        }
        
        let hash = hashPassword(password)
        let user = User(username: username, passwordHash: hash, birthdate: birthdate)
        user.sessionToken = UUID().uuidString
        context.insert(user)
        
        do {
            try context.save()
            currentUser = user
            isAuthenticated = true
            UserDefaults.standard.set(user.sessionToken, forKey: "session_token")
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Failed to create account"
            return false
        }
    }
    
    func login(username: String, password: String) -> Bool {
        guard let context = modelContext else {
            errorMessage = "Database not available"
            return false
        }
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.username == username })
        do {
            let users = try context.fetch(descriptor)
            guard let user = users.first else {
                errorMessage = "Invalid username or password"
                return false
            }
            
            let hash = hashPassword(password)
            guard user.passwordHash == hash else {
                errorMessage = "Invalid username or password"
                return false
            }
            
            user.sessionToken = UUID().uuidString
            try context.save()
            currentUser = user
            isAuthenticated = true
            UserDefaults.standard.set(user.sessionToken, forKey: "session_token")
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Login failed"
            return false
        }
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "session_token")
    }
    
    private func checkExistingSession() {
        guard let context = modelContext else { return }
        guard let token = UserDefaults.standard.string(forKey: "session_token") else { return }
        
        let descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.sessionToken == token })
        do {
            let users = try context.fetch(descriptor)
            if let user = users.first {
                currentUser = user
                isAuthenticated = true
            }
        } catch {
            // ignore
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
