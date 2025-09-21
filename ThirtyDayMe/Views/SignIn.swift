import SwiftData
import SwiftUI

struct SignIn: View {
    @EnvironmentObject var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var isEmailFieldFocused: Bool
    @FocusState private var isPasswordFieldFocused: Bool
    
    func handleSignIn() async {
        print("Sign in with email: \(email)")
        await authService.signIn(email: email, password: password, rememberMe: true)
        print("success?")
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()
            VStack {
                Spacer(minLength: 50)
                
                VStack(spacing: 0) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.primary)
                        .padding(.bottom, 30)
                    
                    Text("Sign in to 30 Day Me")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.bottom, 40)
                    
                    VStack(spacing: 16) {
                        inputField(
                            placeholder: "Email",
                            text: $email,
                            isSecure: false,
                            keyboardType: .emailAddress,
                            onTap: {
                                isEmailFieldFocused = true
                            }
                        )
                        .focused($isEmailFieldFocused)
                        
                        inputField(
                            placeholder: "Password",
                            text: $password,
                            isSecure: true,
                            keyboardType: .default,
                            onTap: {
                                isPasswordFieldFocused = true
                            }
                        )
                        .focused($isPasswordFieldFocused)
                        
                        Button(action: { Task {
                            await handleSignIn()
                        }}) {
                            Text("Sign In")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(UIColor.systemBackground))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.primary)
                                .cornerRadius(28)
                        }
                        
                        Text("or")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                        
                        socialButton(
                            icon: "globe",
                            text: "Continue with Google",
                            action: {}
                        )
                        
                        socialButton(
                            icon: "apple.logo",
                            text: "Continue with Apple",
                            action: {}
                        )
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer(minLength: 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onTapGesture {
            isEmailFieldFocused = false
            isPasswordFieldFocused = false
        }
        .scrollDismissesKeyboard(.interactively)
    }
    
    func inputField(
        placeholder: String,
        text: Binding<String>,
        isSecure: Bool,
        keyboardType: UIKeyboardType,
        onTap: @escaping () -> Void
    ) -> some View {
        HStack {
            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .keyboardType(keyboardType)
                }
            }
            .textFieldStyle(.plain)
            .font(.system(size: 18))
            .foregroundColor(.primary)
            .accentColor(.accentColor)
            .textInputAutocapitalization(.never)
            
            if !text.wrappedValue.isEmpty {
                Button(action: {
                    text.wrappedValue = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(30)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    func socialButton(
        icon: String,
        text: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                Text(text)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    SignIn()
        .environmentObject(AuthService(baseURL: "https://30day.me"))
        .modelContainer(ThirtyDayMeApp.sharedModelContainer)
}
