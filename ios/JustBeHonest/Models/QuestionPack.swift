import Foundation
import SwiftData
import SwiftUI

@Model
final class QuestionPack {
    @Attribute(.unique) var id: UUID
    var title: String
    var ownerId: UUID?
    var createdAt: Date
    var iconName: String?
    var colorName: String?
    @Relationship(deleteRule: .cascade, inverse: \Question.pack) var questions: [Question] = []

    init(title: String, ownerId: UUID? = nil, iconName: String = "rectangle.stack.fill", colorName: String = "indigo") {
        self.id = UUID()
        self.title = title
        self.ownerId = ownerId
        self.createdAt = Date()
        self.iconName = iconName
        self.colorName = colorName
    }

    var resolvedIcon: String {
        iconName ?? "rectangle.stack.fill"
    }

    var resolvedColor: Color {
        PackStyle.color(named: colorName ?? "indigo")
    }
}

enum PackStyle {
    static let icons: [String] = [
        "rectangle.stack.fill",
        "heart.fill",
        "star.fill",
        "flame.fill",
        "sparkles",
        "bolt.fill",
        "moon.stars.fill",
        "sun.max.fill",
        "leaf.fill",
        "gamecontroller.fill",
        "music.note",
        "party.popper.fill",
        "gift.fill",
        "face.smiling.fill",
        "brain.head.profile",
        "lightbulb.fill",
        "book.fill",
        "camera.fill"
    ]

    static let colors: [(name: String, color: Color)] = [
        ("indigo", .indigo),
        ("pink", Color(red: 0.95, green: 0.35, blue: 0.55)),
        ("red", Color(red: 0.92, green: 0.28, blue: 0.36)),
        ("orange", .orange),
        ("yellow", Color(red: 0.95, green: 0.75, blue: 0.15)),
        ("green", Color(red: 0.2, green: 0.75, blue: 0.5)),
        ("teal", .teal),
        ("blue", .blue),
        ("purple", Color(red: 0.55, green: 0.35, blue: 0.85)),
        ("brown", .brown)
    ]

    static func color(named name: String) -> Color {
        colors.first { $0.name == name }?.color ?? .indigo
    }
}
