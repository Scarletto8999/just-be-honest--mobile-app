import SwiftUI

struct PackEditorView: View {
    let packId: UUID
    @State private var questionService: QuestionService

    @State private var pack: QuestionPack?
    @State private var title: String = ""
    @State private var newQuestionText: String = ""
    @State private var editingQuestion: Question?
    @State private var editingText: String = ""
    @State private var questionToDelete: Question?
    @State private var showDeleteAlert: Bool = false
    @FocusState private var isInputFocused: Bool
    @FocusState private var isTitleFocused: Bool

    init(packId: UUID, questionService: QuestionService) {
        self.packId = packId
        self.questionService = questionService
    }

    private var questions: [Question] {
        (pack?.questions ?? []).sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    titleField
                    countBadge
                    addQuestionSection
                    questionsList
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Edit Pack")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { load() }
        .onDisappear { saveTitle() }
        .alert("Delete Question?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { questionToDelete = nil }
            Button("Delete", role: .destructive) {
                if let q = questionToDelete {
                    questionService.deleteQuestion(q)
                    load()
                }
                questionToDelete = nil
            }
        }
        .sheet(item: $editingQuestion) { question in
            editSheet(for: question)
                .presentationDetents([.height(320)])
        }
    }

    private var titleField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Pack Title")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            TextField("Pack title", text: $title)
                .focused($isTitleFocused)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
                .onSubmit { saveTitle() }
        }
    }

    private var countBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "number.circle.fill")
                .foregroundStyle(questions.count >= 10 ? .green : .orange)
            Text("\(questions.count) questions")
                .font(.subheadline)
                .fontWeight(.medium)
            if questions.count >= 10 {
                Text("Ready to play")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.green)
            } else {
                Text("Need \(10 - questions.count) more")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var addQuestionSection: some View {
        VStack(spacing: 12) {
            TextEditor(text: $newQuestionText)
                .focused($isInputFocused)
                .frame(minHeight: 80, maxHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
                .overlay(
                    Group {
                        if newQuestionText.isEmpty {
                            Text("Type a new question…")
                                .foregroundStyle(.tertiary)
                                .padding(16)
                                .allowsHitTesting(false)
                        }
                    },
                    alignment: .topLeading
                )

            HStack {
                Spacer()
                Button(action: addQuestion) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Question")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.indigo)
                    .clipShape(.rect(cornerRadius: 10))
                }
                .disabled(newQuestionText.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newQuestionText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
    }

    private var questionsList: some View {
        VStack(spacing: 10) {
            if questions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("No questions in this pack yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
            } else {
                ForEach(questions) { question in
                    questionRow(question)
                }
            }
        }
    }

    private func questionRow(_ question: Question) -> some View {
        HStack(spacing: 12) {
            Text(question.text)
                .font(.body)
                .lineLimit(4)
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button {
                    editingText = question.text
                    editingQuestion = question
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                Button(role: .destructive) {
                    questionToDelete = question
                    showDeleteAlert = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func editSheet(for question: Question) -> some View {
        VStack(spacing: 16) {
            Text("Edit Question")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 8)

            TextEditor(text: $editingText)
                .frame(minHeight: 120)
                .padding(8)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))

            HStack(spacing: 12) {
                Button("Cancel") { editingQuestion = nil }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))
                    .foregroundStyle(.primary)

                Button {
                    questionService.updateQuestion(question, text: editingText)
                    editingQuestion = nil
                    load()
                } label: {
                    Text("Save").fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.indigo)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12))
                .disabled(editingText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
    }

    private func addQuestion() {
        guard let pack else { return }
        let text = newQuestionText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }

        let success = questionService.addCustomQuestion(text: text, to: pack, userId: pack.ownerId)
        if success {
            newQuestionText = ""
            isInputFocused = false
            load()
        }
    }

    private func load() {
        pack = questionService.fetchPack(id: packId)
        title = pack?.title ?? ""
    }

    private func saveTitle() {
        guard let pack else { return }
        let trimmed = title.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, trimmed != pack.title else { return }
        questionService.renamePack(pack, title: trimmed)
    }
}
