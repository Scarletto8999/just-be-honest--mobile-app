import Foundation

enum TurnDirection: String, Codable {
    case clockwise = "clockwise"
    case counterClockwise = "counter_clockwise"
    
    mutating func toggle() {
        self = (self == .clockwise) ? .counterClockwise : .clockwise
    }
    
    var step: Int {
        self == .clockwise ? 1 : -1
    }
}

@Observable
final class GameSession {
    var players: [Player]
    var currentTurnIndex: Int
    var direction: TurnDirection
    var questions: [Question]
    var answeredQuestionIds: Set<UUID>
    var hostId: UUID
    var gameMode: GameMode
    
    enum GameMode {
        case normal
        case custom
    }
    
    init(players: [Player], questions: [Question], hostId: UUID, gameMode: GameMode) {
        self.players = players
        self.currentTurnIndex = 0
        self.direction = .clockwise
        self.questions = questions
        self.answeredQuestionIds = []
        self.hostId = hostId
        self.gameMode = gameMode
    }
    
    var currentPlayer: Player {
        players[currentTurnIndex]
    }
    
    var availableQuestions: [Question] {
        questions.filter { !answeredQuestionIds.contains($0.id) }
    }
    
    var hasQuestionsLeft: Bool {
        answeredQuestionIds.count < questions.count
    }
    
    var answeredCount: Int {
        answeredQuestionIds.count
    }
    
    func nextTurn() {
        let count = players.count
        currentTurnIndex = (currentTurnIndex + direction.step + count) % count
    }
    
    func getRandomQuestion() -> Question? {
        let available = questions.filter { !answeredQuestionIds.contains($0.id) }
        guard let random = available.randomElement() else { return nil }
        answeredQuestionIds.insert(random.id)
        return random
    }
    
    func shuffleQuestions() {
        let answered = questions.filter { answeredQuestionIds.contains($0.id) }
        var unanswered = questions.filter { !answeredQuestionIds.contains($0.id) }
        unanswered.shuffle()
        questions = answered + unanswered
    }
}
