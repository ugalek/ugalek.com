import FluentPostgreSQL
import Vapor
import Authentication

// A user.
final class User: DatabaseModel {
    
    static let entity = "users"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case password
        case name
        case isAdmin = "is_admin"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var id: Int?
    var username: String
    var password: String
    var name: String?
    var isAdmin: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    
    // Creates a new user.
    init(id: Int? = nil, username: String, password: String, name: String? = nil, isAdmin: Bool? = false) {
        self.id = id
        self.username = username
        self.password = password
        self.name = name
        self.isAdmin = isAdmin
    }
}

extension User: Content {}
extension User: Parameter {}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> {
        return \User.username
    }
    static var passwordKey: WritableKeyPath<User, String> {
        return \User.password
    }
}
extension User: SessionAuthenticatable {}

extension User {
    var posts: Children<User, Post> {
        return children(\.author)
    }
}

public struct AuthUser : Encodable {
    var username: String
    var isAdmin: Bool
}
