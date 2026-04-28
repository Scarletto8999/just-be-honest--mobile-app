import Foundation
import SwiftUI

struct Player: Identifiable, Equatable, Hashable {
    let id: UUID
    var name: String
    var colorName: String
    
    init(name: String, colorName: String) {
        self.id = UUID()
        self.name = name
        self.colorName = colorName
    }
    
    static let playerColors = [
        "indigo",
        "rose",
        "emerald",
        "amber",
        "cyan",
        "violet"
    ]
    
    var swiftUIColor: Color {
        switch colorName {
        case "indigo": return .indigo
        case "rose": return Color(red: 0.92, green: 0.28, blue: 0.36)
        case "emerald": return Color(red: 0.2, green: 0.75, blue: 0.5)
        case "amber": return Color(red: 0.95, green: 0.65, blue: 0.15)
        case "cyan": return Color(red: 0.15, green: 0.7, blue: 0.85)
        case "violet": return Color(red: 0.55, green: 0.35, blue: 0.85)
        default: return .blue
        }
    }
}
