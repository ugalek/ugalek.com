import FluentPostgreSQL
import Vapor

struct UserRepository {
    func findAll(on request: Request) throws -> Future<[User]> {
        return User.query(on: request).all()
    }
}
