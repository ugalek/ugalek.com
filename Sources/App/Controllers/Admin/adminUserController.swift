import Vapor
import Lingo

final class AdminUserController {
    func index(request: Request) throws -> Future<View> {
        let ctx = UserListView(authUser: getAuthUser(session: try request.session()),
                               users: User.query(on: request).all(),
                               baseView: getBaseView(on: request, title: "title.profile")
        )

        return try request.view().render("user", ctx)
    }

    func create(request: Request) throws -> Future<Response> {
        return try request.content.decode(User.self).flatMap { user in
            user.save(on: request).map { _ in
                request.redirect(to: "/users")
            }
        }
    }

    func update(request: Request) throws -> Future<Response> {
        return try request.parameters.next(User.self).flatMap { user in
            try request.content.decode(UserForm.self).flatMap { userForm in
                user.name = userForm.name
                user.isAdmin = userForm.isAdmin
                return user.save(on: request).map { _ in
                    request.redirect(to: "/users")
                }
            }
        }
    }

    func delete(request: Request) throws -> Future<Response> {
        return try request.parameters.next(User.self).flatMap { user in
            try user.posts.query(on: request).delete().flatMap { _ in
                user.delete(on: request).map { _ in
                    request.redirect(to: "/users")
                }
            }
        }
    }
}
