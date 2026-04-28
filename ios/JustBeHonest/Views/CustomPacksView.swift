import SwiftUI

struct CustomPacksView: View {
    @State private var authService: AuthService
    @State private var questionService: QuestionService
    @Binding var path: NavigationPath

    @State private var packs: [QuestionPack] = []
    @State private var showCreatePack: Bool = false
    @State private var newPackTitle: String = ""
    @State private var newPackIcon: String = PackStyle.icons[0]
    @State private var newPackColor: String = PackStyle.colors[0].name
    @State private var packToDelete: QuestionPack?
    @State private var showDeleteAlert: Bool = false
    @State private var showLimitAlert: Bool = false
    @State private var notEnoughAlert: Bool = false

    private let maxPacks = 5

    init(authService: AuthService, questionService: QuestionService, path: Binding<NavigationPath>) {
        self.authService = authService
        self.questionService = questionService
        self._path = path
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerBadge

                    if packs.isEmpty {
                        emptyState
                    } else {
                        ForEach(packs) { pack in
                            packCard(pack)
                        }
                    }

                    if packs.count < maxPacks {
                        addPackButton
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Custom Game")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { refresh() }
        .sheet(isPresented: $showCreatePack) {
            createPackSheet
                .presentationDetents([.medium, .large])
                .presentationContentInteraction(.scrolls)
        }
        .alert("Delete Pack?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { packToDelete = nil }
            Button("Delete", role: .destructive) {
                if let pack = packToDelete {
                    questionService.deletePack(pack)
                    refresh()
                }
                packToDelete = nil
            }
        } message: {
            Text("All questions in this pack will be removed.")
        }
        .alert("Limit reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You can create up to \(maxPacks) custom packs.")
        }
        .alert("Not enough questions", isPresented: $notEnoughAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This pack needs at least 10 questions before you can start a game.")
        }
    }

    private var headerBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "rectangle.stack.fill")
                .foregroundStyle(.indigo)
            Text("\(packs.count)/\(maxPacks) packs")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 44))
                .foregroundStyle(.secondary.opacity(0.5))
            Text("No packs yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Create a pack to write your own questions and play with your group.")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    private func packCard(_ pack: QuestionPack) -> some View {
        let count = pack.questions.count
        let canPlay = count >= 10
        let color = pack.resolvedColor

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
                    Image(systemName: pack.resolvedIcon)
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pack.title)
                        .font(.headline)
                    Text("\(count) questions")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Menu {
                    Button {
                        path.append(GameRoute.packEditor(packId: pack.id))
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }
                    Button(role: .destructive) {
                        packToDelete = pack
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

            HStack(spacing: 10) {
                Button {
                    path.append(GameRoute.packEditor(packId: pack.id))
                } label: {
                    Label("Edit", systemImage: "square.and.pencil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.indigo)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.indigo.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))
                }

                Button {
                    if canPlay {
                        path.append(GameRoute.playerSetup(.custom, packId: pack.id))
                    } else {
                        notEnoughAlert = true
                    }
                } label: {
                    Label("Play", systemImage: "play.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(canPlay ? Color.indigo : Color.gray)
                        .clipShape(.rect(cornerRadius: 10))
                }
                .opacity(canPlay ? 1 : 0.6)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var addPackButton: some View {
        Button {
            if packs.count >= maxPacks {
                showLimitAlert = true
            } else {
                newPackTitle = ""
                newPackIcon = PackStyle.icons[0]
                newPackColor = PackStyle.colors[0].name
                showCreatePack = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                Text("New Pack")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.indigo)
            .clipShape(.rect(cornerRadius: 14))
        }
    }

    private var createPackSheet: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("New Pack")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 8)

                packPreview

                TextField("Pack title", text: $newPackTitle)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(.rect(cornerRadius: 12))

                iconPicker
                colorPicker

                createSheetButtons

                Spacer(minLength: 8)
            }
            .padding(20)
        }
    }

    private var packPreview: some View {
        let color = PackStyle.color(named: newPackColor)
        return ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 92, height: 92)
                .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 6)
            Image(systemName: newPackIcon)
                .font(.system(size: 44))
                .foregroundStyle(.white)
        }
    }

    private var iconPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Icon")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
                ForEach(PackStyle.icons, id: \.self) { icon in
                    let isSelected = icon == newPackIcon
                    Button {
                        withAnimation(.spring(duration: 0.2)) { newPackIcon = icon }
                    } label: {
                        Image(systemName: icon)
                            .font(.system(size: 20))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isSelected ? PackStyle.color(named: newPackColor) : Color(.secondarySystemGroupedBackground))
                            )
                    }
                }
            }
        }
    }

    private var colorPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Color")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PackStyle.colors, id: \.name) { entry in
                        let isSelected = entry.name == newPackColor
                        Circle()
                            .fill(entry.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.primary : .clear, lineWidth: 2.5)
                                    .padding(-3)
                            )
                            .onTapGesture {
                                withAnimation(.spring(duration: 0.2)) { newPackColor = entry.name }
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var createSheetButtons: some View {
        HStack(spacing: 12) {
                Button("Cancel") {
                    showCreatePack = false
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 12))
                .foregroundStyle(.primary)

                Button {
                    let title = newPackTitle.trimmingCharacters(in: .whitespaces)
                    guard !title.isEmpty else { return }
                    let pack = questionService.createPack(title: title, ownerId: authService.currentUser?.id, iconName: newPackIcon, colorName: newPackColor)
                    showCreatePack = false
                    refresh()
                    if let pack {
                        path.append(GameRoute.packEditor(packId: pack.id))
                    }
                } label: {
                    Text("Create")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.indigo)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 12))
                .disabled(newPackTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(newPackTitle.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
        }
    }

    private func refresh() {
        let userId = authService.currentUser?.id
        packs = questionService.fetchPacks(for: userId)
    }
}
