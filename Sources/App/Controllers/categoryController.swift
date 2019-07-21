import Vapor
import Lingo

final class CategoryController {
    func index(request: Request) throws -> Future<View> {
        let ctx = CategoryListView(
            authUser: getAuthUser(session: try request.session()),
            categories: try CategoryRepository().getCategories(on: request),
            baseView: getBaseView(on: request, title: "title.posts")
        )

        return try request.view().render("category", ctx)
    }
    
    func listOfPostsOnCategory(request: Request) throws -> Future<View> {
        let categorySlug = try request.parameters.next(String.self)

        let page = getPageNumper(on: request)
        let range = rangeOfPages(page: page)

        let firstCategory = try CategoryRepository().getBySlug(
            on: request,
            categorySlug: categorySlug
        )

        return firstCategory.flatMap { categories in
            let categoryID = categories.map { category in
                category.id
            }

            let posts = try categories.map { category in
                try category.posts.query(on: request).sort(\.publishedAt, .ascending)
                    .range(lower: range.min, upper: range.max)
                    .join(\Category.id, to: \Post.category)
                    .alsoDecode(Category.self)
                    .all()
                    .map { tuples in
                        tuples.map { tuple in AllPostsContainer(post: tuple.0, category: tuple.1) }
                    }
            }

            let ctx = CategoryView(
                authUser: getAuthUser(session: try request.session()),
                categories: try CategoryRepository().findAll(on: request),
                posts: posts!,
                paginationLinks: try PostRepository().getCategoryPages(on: request, categoryID: categoryID!!, categorySlug: categorySlug),
                baseView: getBaseView(on: request, title: "title.posts")
            )

            return try request.view().render("posts", ctx)
        }
    }
}

struct CategoryListView: Encodable {
    var authUser: AuthUser?
    var categories: Future<[CardOfCats]>
    var baseView: BaseMenuView
}

struct CategoryView: Encodable {
    var authUser: AuthUser?
    var categories: Future<[Category]>
    var posts: Future<[AllPostsContainer]>
    var paginationLinks: Future<[PaginationLinks]>
    var baseView: BaseMenuView
}

