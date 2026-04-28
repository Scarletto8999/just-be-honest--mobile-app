import SwiftUI

struct GamePlayView: View {
    @State var session: GameSession
    @Binding var path: NavigationPath
    
    @State private var currentQuestion: Question?
    @State private var showEndGameAlert: Bool = false
    @State private var cardOffset: CGFloat = 0
    @State private var cardRotation: Double = 0
    @State private var isFlipped: Bool = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    circleSection
                    questionSection
                    controlsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Game On")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { showEndGameAlert = true }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .alert("End Game?", isPresented: $showEndGameAlert) {
            Button("Cancel", role: .cancel) { }
            Button("End Game", role: .destructive) {
                path.removeLast(path.count)
            }
        } message: {
            Text("Are you sure you want to end this game?")
        }
        .onAppear {
            if currentQuestion == nil {
                drawNewQuestion()
            }
        }
    }
    
    private var circleSection: some View {
        VStack(spacing: 12) {
            Text("\(session.currentPlayer.name)'s Turn")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(session.currentPlayer.swiftUIColor)
                .opacity(session.currentTurnIndex == 0 ? 0 : 1)
                .animation(.easeInOut(duration: 0.2), value: session.currentTurnIndex)
            
            ZStack {
                Circle()
                    .stroke(Color(.separator), lineWidth: 1)
                    .frame(width: 280, height: 280)
                
                ForEach(Array(session.players.enumerated()), id: \.element.id) { index, player in
                    let angle = Double(index) * (360.0 / Double(session.players.count)) - 90
                    let isCurrent = index == session.currentTurnIndex
                    
                    playerCircle(player, isCurrent: isCurrent)
                        .offset(
                            x: cos(angle * .pi / 180) * 110,
                            y: sin(angle * .pi / 180) * 110
                        )
                        .scaleEffect(isCurrent ? 1.15 : 1)
                        .animation(.spring(duration: 0.4), value: session.currentTurnIndex)
                }
                
                directionIndicator
            }
            .frame(width: 280, height: 280)
        }
    }
    
    private func playerCircle(_ player: Player, isCurrent: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(player.swiftUIColor)
                    .frame(width: 52, height: 52)
                
                if isCurrent {
                    Circle()
                        .stroke(player.swiftUIColor, lineWidth: 3)
                        .frame(width: 64, height: 64)
                }
                
                Text(String(player.name.prefix(1)).uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            
            Text(player.name)
                .font(.caption)
                .fontWeight(isCurrent ? .semibold : .regular)
                .foregroundStyle(isCurrent ? .primary : .secondary)
                .lineLimit(1)
                .frame(width: 70)
        }
    }
    
    private var directionIndicator: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.3)) {
                session.direction.toggle()
            }
        }) {
            Image(systemName: session.direction == .clockwise ? "arrow.clockwise.circle.fill" : "arrow.counterclockwise.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.indigo)
                .background(
                    Circle()
                        .fill(Color(.systemBackground))
                        .frame(width: 44, height: 44)
                )
        }
    }
    
    private var questionSection: some View {
        VStack(spacing: 16) {
            if let question = currentQuestion {
                flipCard(question)
            } else {
                emptyCard
            }
        }
    }

    private func flipCard(_ question: Question) -> some View {
        ZStack {
            cardBack
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))

            cardFront(question)
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
        }
        .frame(maxWidth: .infinity, minHeight: 260)
        .offset(x: cardOffset)
        .rotationEffect(.degrees(cardRotation))
        .contentShape(.rect(cornerRadius: 20))
        .onTapGesture {
            withAnimation(.spring(duration: 0.6)) {
                isFlipped.toggle()
            }
        }
    }

    private var cardBack: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.app.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white)

            Text("Tap to reveal")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            Text("Be honest")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.8))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.18))
                .clipShape(.capsule)
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.indigo, Color(red: 0.45, green: 0.3, blue: 0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .indigo.opacity(0.3), radius: 14, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func cardFront(_ question: Question) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "quote.opening")
                .font(.system(size: 32))
                .foregroundStyle(.indigo.opacity(0.6))

            Text(question.text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .minimumScaleFactor(0.8)

            HStack(spacing: 6) {
                Image(systemName: categoryIcon(for: question.category))
                    .font(.caption)
                Text(question.category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.tertiarySystemGroupedBackground))
            .clipShape(.capsule)
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 260)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }
    
    private var emptyCard: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            
            Text("All questions answered!")
                .font(.title3)
                .fontWeight(.semibold)
            
            Text("Great conversation. Want to shuffle and play again?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }
    
    private var controlsSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button(action: shuffleQuestions) {
                    HStack(spacing: 6) {
                        Image(systemName: "shuffle")
                        Text("Shuffle")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.indigo)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.indigo.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 12))
                }
                
                if currentQuestion != nil {
                    Button(action: nextTurn) {
                        HStack(spacing: 6) {
                            Text("Next Turn")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.indigo)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
            }
            
            Text("\(session.answeredCount)/\(session.questions.count) answered")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private func categoryIcon(for category: QuestionCategory) -> String {
        switch category {
        case .friendsFamily:
            return "person.2.fill"
        case .couple:
            return "heart.fill"
        case .custom:
            return "square.stack.3d.up.fill"
        }
    }
    
    private func drawNewQuestion() {
        isFlipped = false
        withAnimation(.spring(duration: 0.4)) {
            currentQuestion = session.getRandomQuestion()
        }
    }

    private func nextTurn() {
        withAnimation(.spring(duration: 0.4)) {
            cardOffset = -UIScreen.main.bounds.width
            cardRotation = -10
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            session.nextTurn()
            drawNewQuestion()

            withAnimation(.none) {
                cardOffset = UIScreen.main.bounds.width
                cardRotation = 10
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                withAnimation(.spring(duration: 0.4)) {
                    cardOffset = 0
                    cardRotation = 0
                }
            }
        }
    }

    private func shuffleQuestions() {
        withAnimation(.spring(duration: 0.3)) {
            session.shuffleQuestions()
        }
    }
}
