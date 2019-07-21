import FluentPostgreSQL
import FluentSQL
import Vapor

struct PostRepository {
    func findAll(on request: Request) throws ->
        Future<[AllPostsContainer]> {
        let page = getPageNumper(on: request)
        let range = rangeOfPages(page: page)
        return Post.query(on: request)
            .range(lower: range.min, upper: range.max)
            .sort(\.publishedAt, .descending)
            .join(\Category.id, to: \Post.category)
            .alsoDecode(Category.self)
            .all()
            .map { tuples in
                tuples.map { tuple in AllPostsContainer(post: tuple.0, category: tuple.1) }
            }
    }

    func findAllPosts(on request: Request) throws -> Future<[Post]> {
        return Post.query(on: request)
            .sort(\.publishedAt, .descending)
            .all()
    }

    func findPost(on request: Request, searchString: String) throws ->
        Future<[AllPostsContainer]> {
        let page = getPageNumper(on: request)
        let range = rangeOfPages(page: page)
        return Post.query(on: request)
            .group(.or) { query in
                query.filter(\.title ~~ searchString)
                    .filter(\.text ~~ searchString)
                    .filter(\.preview ~~ searchString)
            }
            .range(lower: range.min, upper: range.max)
            .sort(\.publishedAt, .descending)
            .join(\Category.id, to: \Post.category)
            .alsoDecode(Category.self)
            .all()
            .map { tuples in
                tuples.map { tuple in AllPostsContainer(post: tuple.0, category: tuple.1) }
            }
    }

    func getByID(on request: Request, postID: Int) throws -> Future<Post> {
        return Post.find(postID, on: request).unwrap(or: Abort(BaseRepository().notFoundErr(reason: "Post with ID '\(postID)'")))
    }

    func getBySlug(on request: Request, slug: String) throws -> Future<AllPostsContainer?> {
        return Post.query(on: request)
            .filter(\.slug == slug)
            .join(\Category.id, to: \Post.category)
            .alsoDecode(Category.self)
            .first()
            .map { tuples in
                tuples.map { tuple in AllPostsContainer(post: tuple.0, category: tuple.1) }
            }
    }

    func slugCount(on request: Request, postSlug: String) throws -> Future<Int> {
        return Post.query(on: request)
            .filter(\.slug =~ postSlug)
            .count()
    }

    func getPostPages(on request: Request, s searchString: String = "") throws -> Future<[PaginationLinks]> {
        let fTotalCount = request.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query("SELECT COUNT(*) AS count FROM \"posts\"").map(to: Int.self) { rows in
                try rows[0].firstValue(name: "count")?.decode(Int.self) ?? -1
            }
        }
        return try BaseRepository().getPages(on: request, t: fTotalCount, p: "posts", s: searchString)
    }

    func getCategoryPages(on request: Request, categoryID: Int, categorySlug: String) throws -> Future<[PaginationLinks]> {
        let fTotalCount = request.withPooledConnection(to: .psql) { (conn: PostgreSQLConnection) in
            conn.query(PostgreSQLQuery(stringLiteral: "SELECT COUNT(*) AS count FROM \"posts\" where category=\(categoryID)")).map(to: Int.self) { rows in
                try rows[0].firstValue(name: "count")?.decode(Int.self) ?? -1
            }
        }
        return try BaseRepository().getPages(on: request, t: fTotalCount, p: "categories/\(categorySlug)")
    }
}

struct AllPostsContainer: Content {
    var post: Post
    var category: Category

    init(post: Post, category: Category) {
        self.post = post
        self.category = category
    }
}

struct PaginationLinks: Content {
    var path: String
    var style: String
    var page: String

    init(path: String, style: String, page: String) {
        self.path = path
        self.style = style
        self.page = page
    }
}
