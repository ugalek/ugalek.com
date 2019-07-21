import Crypto
import FluentPostgreSQL
import Vapor
import Lingo

final class UserController {
    func listOfPostsOfUser(_ request: Request) throws -> Future<View> {
        return try UserRepository().findAll(on: request).flatMap { users in
            let userViewList = try users.map { user in
                UserView(
                    user: user,
                    posts: try user.posts.query(on: request).all(),
                    baseView: getBaseView(on: request, title: "title.posts")
                )
            }

            let data = ["userList": userViewList]
            return try request.view().render("user", data)
        }
    }
}

struct UserListView: Encodable {
    var authUser: AuthUser?
    var users: Future<[User]>
    var baseView: BaseMenuView
}

struct UserView: Encodable {
    var user: User
    var posts: Future<[Post]>
    var baseView: BaseMenuView
}
