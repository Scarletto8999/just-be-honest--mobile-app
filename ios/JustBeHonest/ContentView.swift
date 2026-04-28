import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var authService = AuthService()
    @State private var questionService = QuestionService()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                HomeView(authService: authService, questionService: questionService)
            } else {
                AuthView(authService: authService)
            }
        }
        .onAppear {
            authService.setContext(modelContext)
            questionService.setContext(modelContext)
        }
    }
}

#Preview {
    let schema = Schema([User.self, Question.self, QuestionPack.self])
    let container = try! ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
    ContentView()
        .modelContainer(container)
}
