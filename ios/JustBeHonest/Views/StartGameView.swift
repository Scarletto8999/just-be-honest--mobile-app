import SwiftUI

struct StartGameView: View {
    @State private var authService: AuthService
    @Binding var path: NavigationPath
    @State private var showAgeAlert: Bool = false

    init(authService: AuthService, path: Binding<NavigationPath>) {
        self.authService = authService
        self._path = path
    }

    private var isAdult: Bool {
        authService.currentUser?.isAdult ?? false
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose a question category to play with your group.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)

                    MenuCard(
                        title: "Friends & Family",
                        subtitle: "Personal & relationship questions",
                        icon: "person.2.fill",
                        color: .indigo,
                        action: { path.append(GameRoute.playerSetup(.normal, packId: nil)) }
                    )

                    MenuCard(
                        title: "Couple",
                        subtitle: isAdult ? "Relationship & intimacy questions" : "Available for users 18+",
                        icon: "heart.fill",
                        color: Color(red: 0.92, green: 0.28, blue: 0.36),
                        isLocked: !isAdult,
                        action: {
                            if isAdult {
                                path.append(GameRoute.playerSetup(.couple, packId: nil))
                            } else {
                                showAgeAlert = true
                            }
                        }
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Start Game")
        .navigationBarTitleDisplayMode(.large)
        .alert("18+ Only", isPresented: $showAgeAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Couple mode is locked for users under 18.")
        }
    }
}
