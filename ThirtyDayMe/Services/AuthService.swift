import SwiftUI
import Foundation



@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let baseURL: String
    private let keychain = KeychainHelper.shared
    
    init(baseURL: String) {
        self.baseURL = baseURL
        checkAuthStatus()
    }
    
    private func makeRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw AuthError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add bearer token if available
        if let token = keychain.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AuthError.invalidResponse
        }
        
        // Handle successful responses
        if 200...299 ~= httpResponse.statusCode {
            // Check for bearer token in response headers
            if let token = httpResponse.value(forHTTPHeaderField: "set-auth-token") {
                try keychain.saveToken(token)
            }

            // Handle empty response or when expecting EmptyResponse
            if data.isEmpty || responseType == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw API response: \(jsonString)")
            }

            return try JSONDecoder().decode(responseType, from: data)
        }
        
        // Handle errors
        if httpResponse.statusCode == 401 {
            throw AuthError.unauthorized
        }
        
        if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let message = errorData["message"] as? String {
            throw AuthError.serverError(message)
        }
        
        throw AuthError.serverError("Request failed with status \(httpResponse.statusCode)")
    }
    
    func signIn(email: String, password: String, rememberMe: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            let requestBody = SignInRequest(email: email, password: password, rememberMe: rememberMe)
            let bodyData = try JSONEncoder().encode(requestBody)

            let response = try await makeRequest(
                endpoint: "/api/auth/sign-in/email",
                method: "POST",
                body: bodyData,
                responseType: AuthResponse.self
            )

            print("Sign in response - User: \(String(describing: response.user))")
            print("Sign in response - Session: \(String(describing: response.session))")

            // Save the token from the session
            if let session = response.session {
                try keychain.saveToken(session.token)
                print("Token saved successfully")
            } else {
                print("No session in response")
            }

            self.user = response.user
            self.isAuthenticated = response.user != nil
            print("isAuthenticated set to: \(self.isAuthenticated)")

        } catch {
            print("Sign in error: \(error)")
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func signUp(email: String, password: String, name: String? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let requestBody = SignUpRequest(email: email, password: password, name: name)
            let bodyData = try JSONEncoder().encode(requestBody)

            let response = try await makeRequest(
                endpoint: "/api/auth/sign-up/email",
                method: "POST",
                body: bodyData,
                responseType: AuthResponse.self
            )

            // Save the token from the session
            if let session = response.session {
                try keychain.saveToken(session.token)
            }

            self.user = response.user
            self.isAuthenticated = response.user != nil

        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
    
    func signOut() async {
        isLoading = true

        do {
            // Send empty JSON object instead of nil
            let emptyBody = try JSONEncoder().encode([String: String]())

            _ = try await makeRequest(
                endpoint: "/api/auth/sign-out",
                method: "POST",
                body: emptyBody,
                responseType: EmptyResponse.self
            )
        } catch {
            // Log error but still clear local state
            print("Sign out error: \(error)")
        }

        keychain.deleteToken()
        self.user = nil
        self.isAuthenticated = false
        isLoading = false
    }
    
    func checkAuthStatus() {
        guard keychain.getToken() != nil else {
            self.isAuthenticated = false
            return
        }
        
        Task {
            do {
                let response = try await makeRequest(
                    endpoint: "/api/auth/get-session",
                    method: "GET",
                    body: nil,
                    responseType: AuthResponse.self
                )
                
                self.user = response.user
                self.isAuthenticated = response.user != nil
                
            } catch AuthError.unauthorized {
                // Token is invalid, clear it
                keychain.deleteToken()
                self.isAuthenticated = false
                self.user = nil
            } catch {
                print("Auth check error: \(error)")
                // Keep existing state on network errors
            }
        }
    }
    
    func makeAuthenticatedRequest<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await makeRequest(
            endpoint: endpoint,
            method: method,
            body: body,
            responseType: responseType
        )
    }
}

struct EmptyResponse: Codable {
    init() {}
}
