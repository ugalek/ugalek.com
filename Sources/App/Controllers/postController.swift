import FluentPostgreSQL
import Lingo
import Slugify
import SwiftMarkdown
import Vapor

typealias Row = [PostgreSQLColumn: PostgreSQLData]

final class PostController {
    func index(request: Request) throws -> Future<View> {
        if let searchString = request.query[String.self, at: "q"] {
            return try request.view().render("posts", PostListView(
                authUser: getAuthUser(session: try request.session()),
                posts: try PostRepository().findPost(on: request, searchString: searchString),
                categories: CategoryRepository().findAll(on: request),
                paginationLinks: PostRepository().getPostPages(on: request, s: "&q=" + searchString),
                baseView: getBaseView(on: request, title: "title.posts")
            ))
        } else {
            return try request.view().render("posts", PostListView(
                authUser: getAuthUser(session: try request.session()),
                posts: try PostRepository().findAll(on: request),
                categories: CategoryRepository().findAll(on: request),
                paginationLinks: PostRepository().getPostPages(on: request),
                baseView: getBaseView(on: request, title: "title.posts")
            ))
        }
    }

    func detail(request: Request) throws -> Future<View> {
        let postFuture = try PostRepository().getBySlug(on: request, slug: try request.parameters.next(String.self))

        return postFuture.flatMap(to: View.self) { post in
            try request.view().render("post_detail", PostDetailView(
                authUser: getAuthUser(session: try request.session()),
                categories: CategoryRepository().findAll(on: request),
                post: post,
                imgPath: getRandomTitle(),
                socials: getPathToSocial(on: request),
                baseView: getBaseView(on: request, title: "title.posts")
            ))
        }
    }

    func showCreate(request: Request) throws -> Future<View> {
        return try request.view().render("post", PostCreateView(
            user: try request.requireAuthenticated(User.self),
            categories: try CategoryRepository().findAll(on: request),
            action: "/post",
            baseView: getBaseView(on: request, title: "title.posts")
        ))
    }

    func showEdit(request: Request) throws -> Future<View> {
        let postID = try request.parameters.next(Int.self)

        return try request.view().render("post", PostEditView(
            user: try request.requireAuthenticated(User.self),
            categories: try CategoryRepository().findAll(on: request),
            post: PostRepository().getByID(on: request, postID: postID),
            action: "/post/\(postID)/update",
            baseView: getBaseView(on: request, title: "title.posts")
        ))
    }

    func create(request: Request) throws -> Future<Response> {
        return try request.content
            .decode(PostForm.self)
            .flatMap { postForm in
                User
                    .find(postForm.author, on: request)
                    .flatMap { user in
                        guard let author = try user?.requireID() else {
                            throw Abort(.badRequest)
                        }
                        var slug = postForm.title.slugify()

                        let post = try PostRepository().slugCount(on: request, postSlug: slug).map(to: Post.self) { slugCount in
                            if slugCount != 0 {
                                slug = slug + "-" + String(slugCount)
                            }

                            return Post(
                                author: author,
                                title: postForm.title,
                                text: postForm.text,
                                textHtml: try markdownToHTML(postForm.text, options: []),
                                preview: postForm.preview,
                                categoryID: postForm.category,
                                publishedAt: formatStringToDate(date: postForm.publishedAt),
                                slug: slug,
                                lang: postForm.lang,
                                isPublished: postForm.isPublished == "on" ? true : false
                            )
                        }

                        return post.save(on: request).map { _ in
                            request.redirect(to: "/posts")
                        }
                    }
            }
    }

    func update(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Post.self).flatMap { post in
            try request.content.decode(PostForm.self).flatMap { postForm in
                post.author = postForm.author
                post.title = postForm.title
                post.text = postForm.text
                post.textHtml = try markdownToHTML(postForm.text, options: [])
                post.preview = postForm.preview
                post.category = postForm.category
                post.publishedAt = formatStringToDate(date: postForm.publishedAt)
                post.isPublished = postForm.isPublished == "on" ? true : false
                post.lang = postForm.lang

                if postForm.pslug != postForm.slug {
                    post.slug = postForm.slug
                }

                return post.save(on: request).map { _ in
                    request.redirect(to: "/posts")
                }
            }
        }
    }
}

struct PostCreateView: Encodable {
    var user: User
    var categories: Future<[Category]>
    var action: String
    var baseView: BaseMenuView
}

struct PostEditView: Encodable {
    var user: User
    var categories: Future<[Category]>
    var post: Future<Post>
    var action: String
    var baseView: BaseMenuView
}

struct PostListView: Encodable {
    var authUser: AuthUser?
    var posts: Future<[AllPostsContainer]>
    var categories: Future<[Category]>
    var paginationLinks: Future<[PaginationLinks]>
    var baseView: BaseMenuView
}

struct PostDetailView: Encodable {
    var authUser: AuthUser?
    var categories: Future<[Category]>
    var post: AllPostsContainer?
    var imgPath: String
    var socials: [PathToSocial]
    var baseView: BaseMenuView
}
