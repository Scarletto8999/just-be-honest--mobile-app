import Foundation
import SwiftData

@Observable
final class QuestionService {
    private var modelContext: ModelContext?

    func setContext(_ context: ModelContext) {
        self.modelContext = context
        seedBuiltInQuestionsIfNeeded()
    }

    func fetchQuestions(category: QuestionCategory? = nil) -> [Question] {
        guard let context = modelContext else { return [] }

        let descriptor: FetchDescriptor<Question>
        if let category = category {
            let raw = category.rawValue
            descriptor = FetchDescriptor<Question>(predicate: #Predicate { $0.categoryRaw == raw })
        } else {
            descriptor = FetchDescriptor<Question>()
        }

        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }

    // MARK: - Packs

    func fetchPacks(for userId: UUID? = nil) -> [QuestionPack] {
        guard let context = modelContext else { return [] }
        let descriptor: FetchDescriptor<QuestionPack>
        if let userId {
            descriptor = FetchDescriptor<QuestionPack>(
                predicate: #Predicate { $0.ownerId == userId },
                sortBy: [SortDescriptor(\.createdAt)]
            )
        } else {
            descriptor = FetchDescriptor<QuestionPack>(sortBy: [SortDescriptor(\.createdAt)])
        }
        do {
            return try context.fetch(descriptor)
        } catch {
            return []
        }
    }

    func fetchPack(id: UUID) -> QuestionPack? {
        guard let context = modelContext else { return nil }
        let descriptor = FetchDescriptor<QuestionPack>(predicate: #Predicate { $0.id == id })
        return (try? context.fetch(descriptor))?.first
    }

    @discardableResult
    func createPack(title: String, ownerId: UUID?, iconName: String = "rectangle.stack.fill", colorName: String = "indigo") -> QuestionPack? {
        guard let context = modelContext else { return nil }
        let pack = QuestionPack(title: title, ownerId: ownerId, iconName: iconName, colorName: colorName)
        context.insert(pack)
        try? context.save()
        return pack
    }

    func renamePack(_ pack: QuestionPack, title: String) {
        guard let context = modelContext else { return }
        pack.title = title
        try? context.save()
    }

    func updatePackStyle(_ pack: QuestionPack, iconName: String, colorName: String) {
        guard let context = modelContext else { return }
        pack.iconName = iconName
        pack.colorName = colorName
        try? context.save()
    }

    func deletePack(_ pack: QuestionPack) {
        guard let context = modelContext else { return }
        context.delete(pack)
        try? context.save()
    }

    // MARK: - Custom questions inside a pack

    @discardableResult
    func addCustomQuestion(text: String, to pack: QuestionPack, userId: UUID?) -> Bool {
        guard let context = modelContext else { return false }
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        let question = Question(text: trimmed, category: .custom, createdBy: userId)
        question.pack = pack
        context.insert(question)
        try? context.save()
        return true
    }

    func updateQuestion(_ question: Question, text: String) {
        guard let context = modelContext else { return }
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        question.text = trimmed
        try? context.save()
    }

    func deleteQuestion(_ question: Question) {
        guard let context = modelContext else { return }
        context.delete(question)
        try? context.save()
    }

    private func seedBuiltInQuestionsIfNeeded() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<Question>(
            predicate: #Predicate { $0.createdBy == nil }
        )
        do {
            let existing = try context.fetch(descriptor)
            guard existing.isEmpty else { return }

            for text in BuiltInQuestions.friendsFamily {
                let q = Question(text: text, category: .friendsFamily)
                context.insert(q)
            }

            for text in BuiltInQuestions.couple {
                let q = Question(text: text, category: .couple)
                context.insert(q)
            }

            try context.save()
        } catch {
            print("Failed to seed questions: \(error)")
        }
    }
}
