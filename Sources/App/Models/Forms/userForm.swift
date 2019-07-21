import Vapor

struct UserForm: Content {
    var name: String
    var isAdmin: Bool
}
