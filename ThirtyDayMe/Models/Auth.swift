import Foundation

struct User: Codable {
    let id: String
    let email: String
    let name: String?
    let image: String?
    let emailVerified: Bool
    let createdAt: String
    let updatedAt: String
}

struct AuthResponse: Codable {
    let user: User?
    let session: SessionData?
}

struct SessionData: Codable {
    let id: String
    let userId: String
    let expiresAt: String
    let token: String
    let ipAddress: String?
    let userAgent: String?
}

struct SignInRequest: Codable {
    let email: String
    let password: String
    let rememberMe: Bool?
}

struct SignUpRequest: Codable {
    let email: String
    let password: String
    let name: String?
}

enum AuthError: Error {
    case invalidURL
    case noData
    case invalidResponse
    case unauthorized
    case serverError(String)
    case tokenNotFound
    case keychainError
}
