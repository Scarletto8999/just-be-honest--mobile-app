import SwiftUI

struct HomeView: View {
    @State private var authService: AuthService
    @State private var questionService: QuestionService
    @State private var path = NavigationPath()

    init(authService: AuthService, questionService: QuestionService) {
        self.authService = authService
        self.questionService = questionService
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        headerSection
                        menuGrid
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button(role: .destructive, action: { authService.logout() }) {
                            Label("Sign Out", systemImage: "arrow.right.circle.fill")
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.indigo)
                    }
                }
            }
            .navigationDestination(for: GameRoute.self) { route in
                switch route {
                case .startGame:
                    StartGameView(authService: authService, path: $path)
                case .customPacks:
                    CustomPacksView(authService: authService, questionService: questionService, path: $path)
                case .packEditor(let packId):
                    PackEditorView(packId: packId, questionService: questionService)
                case .howToPlay:
                    HowToPlayView()
                case .playerSetup(let mode, let packId):
                    PlayerSetupView(
                        authService: authService,
                        questionService: questionService,
                        gameMode: mode,
                        packId: packId,
                        path: $path
                    )
                case .gamePlay(let session):
                    GamePlayView(session: session, path: $path)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Hello, \(authService.currentUser?.username ?? "Player")")
                .font(.title)
                .fontWeight(.bold)

            Text("Gather around and be honest")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var menuGrid: some View {
        VStack(spacing: 16) {
            MenuCard(
                title: "Start Game",
                subtitle: "Pick Friends & Family or Couple",
                icon: "play.circle.fill",
                color: .indigo,
                action: { path.append(GameRoute.startGame) }
            )

            MenuCard(
                title: "Custom Game",
                subtitle: "Create and play your own packs",
                icon: "square.stack.3d.up.fill",
                color: Color(red: 0.2, green: 0.75, blue: 0.5),
                action: { path.append(GameRoute.customPacks) }
            )

            MenuCard(
                title: "How to Play",
                subtitle: "Rules and how the game works",
                icon: "questionmark.circle.fill",
                color: Color(red: 0.55, green: 0.35, blue: 0.85),
                action: { path.append(GameRoute.howToPlay) }
            )
        }
    }
}

enum GameRoute: Hashable {
    case startGame
    case customPacks
    case packEditor(packId: UUID)
    case howToPlay
    case playerSetup(GameMode, packId: UUID?)
    case gamePlay(GameSession)

    static func == (lhs: GameRoute, rhs: GameRoute) -> Bool {
        switch (lhs, rhs) {
        case (.startGame, .startGame): return true
        case (.customPacks, .customPacks): return true
        case (.howToPlay, .howToPlay): return true
        case (.packEditor(let a), .packEditor(let b)): return a == b
        case (.playerSetup(let a, let aId), .playerSetup(let b, let bId)): return a == b && aId == bId
        case (.gamePlay(let a), .gamePlay(let b)): return a === b
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .startGame: hasher.combine("startGame")
        case .customPacks: hasher.combine("customPacks")
        case .howToPlay: hasher.combine("howToPlay")
        case .packEditor(let id):
            hasher.combine("packEditor")
            hasher.combine(id)
        case .playerSetup(let mode, let packId):
            hasher.combine("playerSetup")
            hasher.combine(mode)
            hasher.combine(packId)
        case .gamePlay(let s):
            hasher.combine("gamePlay")
            hasher.combine(ObjectIdentifier(s))
        }
    }
}

struct MenuCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)

                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .disabled(isLocked)
        .opacity(isLocked ? 0.5 : 1)
    }
}
