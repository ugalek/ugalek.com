import Authentication
import Vapor
import Lingo

final class AuthController {
    // MARK: - Register

    func showRegister(request: Request) throws -> Future<View> {
        let ctx = LoginView(baseView: getBaseView(on: request, title: "title.login"))
        return try request.view().render("register", ctx)
    }

    func register(request: Request) throws -> Future<Response> {
        return try request.content.decode(User.self).flatMap { user in
            User.query(on: request).filter(\User.username == user.username).first().flatMap { result in
                if let _ = result {
                    return Future.map(on: request) {
                        request.redirect(to: "/register")
                    }
                }
                user.password = try BCrypt.hash(user.password)
                user.isAdmin = false
                return user.save(on: request).map { _ in
                    request.redirect(to: "/login")
                }
            }
        }
    }

    // MARK: - Login

    func login(request: Request) throws -> Future<View> {
        let ctx = LoginView(baseView: getBaseView(on: request, title: "title.login"))
        
        return try request.view().render("login", ctx)
    }

    func login(request: Request, form: LoginForm) throws -> Future<Response> {
        return User.authenticate(username: form.username, password: form.password, using: BCryptDigest(), on: request)
            .unwrap(or: Abort(.unauthorized))
            .map { user -> Response in
                try request.authenticateSession(user)
                let session = try request.session()
                session["username"] = user.username
                session["isAdmin"] = String(user.isAdmin!)

                return request.redirect(to: "/profile")
            }
            .catchMap { _ in
                request.redirect(to: "/login")
            }
    }

    // MARK: - Logout

    func logout(request: Request) throws -> Future<Response> {
        try request.unauthenticateSession(User.self)
        let session = try request.session()
        session["username"] = nil
        session["isAdmin"] = nil
        return Future.map(on: request) { request.redirect(to: "/login") }
    }

    // MARK: - Profile

    func profile(request: Request) throws -> Future<View> {
        let ctx = ProfileView(authUser: getAuthUser(session: try request.session()),
                              user: try request.requireAuthenticated(User.self),
                              baseView: getBaseView(on: request, title: "title.profile")
        )
        return try request.view().render("profile", ctx)
    }
}

struct ProfileView: Encodable {
    var authUser: AuthUser?
    var user: User
    var baseView: BaseMenuView
}


struct LoginView: Encodable {
    var baseView: BaseMenuView
}
