import Foundation
import SwiftData

@Model
final class User {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var username: String
    var passwordHash: String
    var birthdate: Date
    var sessionToken: String?
    var createdAt: Date
    
    init(username: String, passwordHash: String, birthdate: Date) {
        self.id = UUID()
        self.username = username
        self.passwordHash = passwordHash
        self.birthdate = birthdate
        self.sessionToken = nil
        self.createdAt = Date()
    }
    
    var age: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: birthdate, to: Date())
        return components.year ?? 0
    }
    
    var isAdult: Bool {
        age >= 18
    }
}
