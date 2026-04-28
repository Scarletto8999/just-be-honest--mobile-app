import Foundation
import SwiftData

enum QuestionCategory: String, Codable, CaseIterable {
    case friendsFamily = "friends_family"
    case couple = "couple"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .friendsFamily:
            return "Friends & Family"
        case .couple:
            return "Couples"
        case .custom:
            return "Custom"
        }
    }
}

@Model
final class Question {
    @Attribute(.unique) var id: UUID
    var text: String
    var categoryRaw: String
    var createdBy: UUID?
    var createdAt: Date
    var pack: QuestionPack?
    
    var category: QuestionCategory {
        QuestionCategory(rawValue: categoryRaw) ?? .friendsFamily
    }
    
    init(text: String, category: QuestionCategory, createdBy: UUID? = nil) {
        self.id = UUID()
        self.text = text
        self.categoryRaw = category.rawValue
        self.createdBy = createdBy
        self.createdAt = Date()
    }
}
