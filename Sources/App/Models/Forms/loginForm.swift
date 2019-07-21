import Vapor

struct LoginForm: Content {
    let username: String
    let password: String
}
