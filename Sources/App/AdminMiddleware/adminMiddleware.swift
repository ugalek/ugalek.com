import Vapor

struct AdminMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Future<Response> {
        let user = try request.authenticated(User.self)
        if user?.isAdmin == false {
            throw Abort(.unauthorized)
        }
        return try next.respond(to: request)
    }
}
