import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    rule(
                        icon: "person.3.fill",
                        color: .indigo,
                        title: "Gather 2–6 players",
                        text: "Sit in a circle. Everyone takes turns answering honestly."
                    )
                    rule(
                        icon: "rectangle.stack.fill",
                        color: Color(red: 0.2, green: 0.75, blue: 0.5),
                        title: "Pick a category",
                        text: "Friends & Family, Couple (18+), or your own custom pack."
                    )
                    rule(
                        icon: "arrow.triangle.2.circlepath",
                        color: Color(red: 0.55, green: 0.35, blue: 0.85),
                        title: "Take turns",
                        text: "The highlighted player answers the question shown. Tap Next Turn to pass to the next player."
                    )
                    rule(
                        icon: "shuffle",
                        color: .orange,
                        title: "Shuffle anytime",
                        text: "Don't like the question? Shuffle the deck to draw a new one."
                    )
                    rule(
                        icon: "hand.raised.fill",
                        color: .pink,
                        title: "Be honest",
                        text: "No judgment, no phones, no skipping (unless the group agrees). Keep it kind."
                    )
                    rule(
                        icon: "square.and.pencil",
                        color: .teal,
                        title: "Make your own",
                        text: "Create up to 5 custom packs in Custom Game. Each pack needs at least 10 questions to play."
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("How to Play")
        .navigationBarTitleDisplayMode(.large)
    }

    private func rule(icon: String, color: Color, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }
}
