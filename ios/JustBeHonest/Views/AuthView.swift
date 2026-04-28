import SwiftUI

struct AuthView: View {
    @State private var authService: AuthService
    @State private var isRegistering: Bool = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var birthdate: Date = Calendar.current.date(byAdding: .year, value: -20, to: Date()) ?? Date()
    @State private var isLoading: Bool = false
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var rememberMe: Bool = true

    @AppStorage("saved_username") private var savedUsername: String = ""
    @AppStorage("saved_password") private var savedPassword: String = ""
    @AppStorage("remember_me") private var rememberMeStored: Bool = true

    init(authService: AuthService) {
        self.authService = authService
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    headerSection
                    formSection
                    if !isRegistering {
                        rememberMeRow
                    }
                    actionButton
                    toggleModeButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .padding(.bottom, 40)
            }
        }
        .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") { authService.errorMessage = nil }
        } message: {
            Text(authService.errorMessage ?? "")
        }
        .onAppear {
            rememberMe = rememberMeStored
            if rememberMeStored {
                username = savedUsername
                password = savedPassword
                if !savedUsername.isEmpty && !savedPassword.isEmpty && !authService.isAuthenticated {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(150))
                        _ = authService.login(username: savedUsername, password: savedPassword)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 72))
                .foregroundStyle(.indigo)

            Text("Just Be Honest")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(isRegistering ? "Create your account" : "Welcome back")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    private var formSection: some View {
        VStack(spacing: 16) {
            usernameField
            passwordField(text: $password, show: $showPassword, placeholder: "Password")

            if isRegistering {
                passwordField(text: $confirmPassword, show: $showConfirmPassword, placeholder: "Confirm Password")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Birthdate")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)

                    DatePicker("", selection: $birthdate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .frame(height: 120)
                        .padding(.horizontal, 4)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(.rect(cornerRadius: 12))
                }
            }
        }
    }

    private var usernameField: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .foregroundStyle(.secondary)
            TextField("", text: $username, prompt: Text("Username").foregroundStyle(.secondary))
                .textContentType(.username)
                .autocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func passwordField(text: Binding<String>, show: Binding<Bool>, placeholder: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.fill")
                .foregroundStyle(.secondary)

            Group {
                if show.wrappedValue {
                    TextField("", text: text, prompt: Text(placeholder).foregroundStyle(.secondary))
                        .textContentType(.password)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } else {
                    SecureField("", text: text, prompt: Text(placeholder).foregroundStyle(.secondary))
                        .textContentType(.password)
                }
            }

            Button(action: { show.wrappedValue.toggle() }) {
                Image(systemName: show.wrappedValue ? "eye.slash.fill" : "eye.fill")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var rememberMeRow: some View {
        Toggle(isOn: $rememberMe) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(.indigo)
                Text("Stay signed in")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .tint(.indigo)
        .padding(.horizontal, 4)
    }

    private var actionButton: some View {
        Button(action: performAction) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.indigo)

                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(isRegistering ? "Create Account" : "Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(height: 54)
        .disabled(isLoading || username.isEmpty || password.isEmpty)
        .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1)
    }

    private var toggleModeButton: some View {
        Button(action: {
            withAnimation(.spring(duration: 0.3)) {
                isRegistering.toggle()
                authService.errorMessage = nil
            }
        }) {
            Text(isRegistering ? "Already have an account? Sign In" : "Don't have an account? Create one")
                .font(.subheadline)
                .foregroundStyle(.indigo)
        }
    }

    private func performAction() {
        guard !isLoading else { return }
        isLoading = true

        Task {
            var success = false
            if isRegistering {
                guard password == confirmPassword else {
                    authService.errorMessage = "Passwords do not match"
                    isLoading = false
                    return
                }
                success = authService.register(username: username, password: password, birthdate: birthdate)
            } else {
                success = authService.login(username: username, password: password)
            }

            if success {
                rememberMeStored = rememberMe
                if rememberMe {
                    savedUsername = username
                    savedPassword = password
                } else {
                    savedUsername = ""
                    savedPassword = ""
                }
            }
            isLoading = false
        }
    }
}
