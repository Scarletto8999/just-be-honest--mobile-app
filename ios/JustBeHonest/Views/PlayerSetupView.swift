import SwiftUI
import SwiftData

enum GameMode: String, Hashable {
    case normal
    case couple
    case custom
}

struct PlayerSetupView: View {
    @State private var authService: AuthService
    @State private var questionService: QuestionService
    let gameMode: GameMode
    let packId: UUID?
    @Binding var path: NavigationPath

    @State private var players: [Player] = []
    @State private var newPlayerName: String = ""
    @State private var selectedColorIndex: Int = 0
    @State private var showValidationError: Bool = false
    @State private var validationMessage: String = ""
    @State private var editingPlayer: Player?
    @State private var editingName: String = ""
    @FocusState private var isNameFocused: Bool

    init(authService: AuthService, questionService: QuestionService, gameMode: GameMode, packId: UUID?, path: Binding<NavigationPath>) {
        self.authService = authService
        self.questionService = questionService
        self.gameMode = gameMode
        self.packId = packId
        self._path = path
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    playerListSection
                    addPlayerSection
                    startButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Players")
        .navigationBarTitleDisplayMode(.large)
        .alert("Cannot Start", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .sheet(item: $editingPlayer) { player in
            renameSheet(for: player)
                .presentationDetents([.height(220)])
        }
        .onAppear {
            if players.isEmpty, let username = authService.currentUser?.username {
                players.append(Player(name: username, colorName: Player.playerColors[0]))
            }
        }
    }

    private var maxPlayers: Int {
        gameMode == .couple ? 2 : 6
    }

    private var minPlayers: Int {
        gameMode == .couple ? 2 : 2
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(modeDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(gameMode == .couple ? "\(players.count)/2 players (couple mode)" : "\(players.count)/6 players")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.indigo)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.indigo.opacity(0.1))
                .clipShape(.capsule)
        }
    }

    private var modeDescription: String {
        switch gameMode {
        case .normal:
            return "Add 1–5 friends to play with built-in Friends & Family questions"
        case .couple:
            return "Add your partner to explore relationship questions together"
        case .custom:
            return "Add friends and play with your custom pack"
        }
    }

    private var playerListSection: some View {
        VStack(spacing: 12) {
            ForEach(players) { player in
                playerRow(player)
            }
        }
    }

    private func playerRow(_ player: Player) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(player.swiftUIColor)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(player.name.prefix(1)).uppercased())
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(player.name)
                    .font(.body)
                    .fontWeight(.medium)

                if player.id == players.first?.id {
                    Text("Host")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.indigo)
                }
            }

            Spacer()

            Button {
                editingName = player.name
                editingPlayer = player
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.indigo)
            }

            if player.id != players.first?.id {
                Button(action: { removePlayer(player) }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func renameSheet(for player: Player) -> some View {
        VStack(spacing: 16) {
            Text("Edit Player Name")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 8)

            TextField("Player name", text: $editingName)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))

            HStack(spacing: 12) {
                Button("Cancel") { editingPlayer = nil }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                    .foregroundStyle(.primary)

                Button {
                    let trimmed = editingName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty,
                       let idx = players.firstIndex(where: { $0.id == player.id }) {
                        players[idx].name = trimmed
                    }
                    editingPlayer = nil
                } label: {
                    Text("Save").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.indigo)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12))
                .disabled(editingName.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private var addPlayerSection: some View {
        VStack(spacing: 12) {
            if players.count < maxPlayers {
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        TextField("Player name", text: $newPlayerName)
                            .focused($isNameFocused)

                        if !newPlayerName.isEmpty {
                            Button(action: { newPlayerName = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))

                    Button(action: addPlayer) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.indigo)
                    }
                    .disabled(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.4 : 1)
                }

                HStack(spacing: 10) {
                    ForEach(0..<Player.playerColors.count, id: \.self) { index in
                        let color = Player.playerColors[index]
                        let isSelected = selectedColorIndex == index
                        let isUsed = players.contains { $0.colorName == color }

                        Circle()
                            .fill(Player(name: "", colorName: color).swiftUIColor)
                            .frame(width: 32, height: 32)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.primary : Color.clear, lineWidth: 2.5)
                            )
                            .opacity(isUsed && !isSelected ? 0.3 : 1)
                            .onTapGesture {
                                if !isUsed || isSelected {
                                    withAnimation(.spring(duration: 0.2)) {
                                        selectedColorIndex = index
                                    }
                                }
                            }
                    }
                }
            }
        }
    }

    private var canStart: Bool {
        if gameMode == .couple {
            return players.count == 2
        }
        return players.count >= 2
    }

    private var startButton: some View {
        Button(action: startGame) {
            HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("Start Game")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Color.indigo)
            .clipShape(.rect(cornerRadius: 14))
        }
        .disabled(!canStart)
        .opacity(canStart ? 1 : 0.5)
    }

    private func addPlayer() {
        let name = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty, players.count < maxPlayers else { return }

        let color = Player.playerColors[selectedColorIndex]
        let newPlayer = Player(name: name, colorName: color)
        players.append(newPlayer)
        newPlayerName = ""

        for i in 0..<Player.playerColors.count {
            if !players.contains(where: { $0.colorName == Player.playerColors[i] }) {
                selectedColorIndex = i
                break
            }
        }
    }

    private func removePlayer(_ player: Player) {
        withAnimation(.spring(duration: 0.3)) {
            players.removeAll { $0.id == player.id }
        }
    }

    private func startGame() {
        if gameMode == .couple {
            guard players.count == 2 else {
                validationMessage = "Couple mode needs exactly 2 players"
                showValidationError = true
                return
            }
        } else {
            guard players.count >= 2 else {
                validationMessage = "You need at least 2 players to start"
                showValidationError = true
                return
            }
        }

        let questions: [Question]
        switch gameMode {
        case .normal:
            questions = questionService.fetchQuestions(category: .friendsFamily)
        case .couple:
            questions = questionService.fetchQuestions(category: .couple)
        case .custom:
            guard let packId, let pack = questionService.fetchPack(id: packId) else {
                validationMessage = "This pack could not be loaded"
                showValidationError = true
                return
            }
            guard pack.questions.count >= 10 else {
                validationMessage = "This pack needs at least 10 questions. It currently has \(pack.questions.count)."
                showValidationError = true
                return
            }
            questions = pack.questions
        }

        guard !questions.isEmpty else {
            validationMessage = "No questions available for this mode"
            showValidationError = true
            return
        }

        let session = GameSession(
            players: players,
            questions: questions,
            hostId: players.first?.id ?? UUID(),
            gameMode: gameMode == .custom ? .custom : .normal
        )

        path.append(GameRoute.gamePlay(session))
    }
}
