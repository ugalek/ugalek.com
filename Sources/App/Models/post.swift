import FluentPostgreSQL
import Vapor

// A post.
final class Post: DatabaseModel {
    
    static let entity = "posts"
    static let titleLength = 128
    
    private enum CodingKeys: String, CodingKey {
        case id
        case author
        case title
        case text
        case textHtml = "text_html"
        case preview
        case category
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case publishedAt = "published_at"
        case isPublished = "is_published"
        case slug
        case lang
    }
    
    var id: Int?
    var author: User.ID
    var title: String
    var text: String
    var textHtml: String
    var preview: String
    var category: Category.ID?
    var createdAt: Date?
    var updatedAt: Date?
    var publishedAt: Date
    var isPublished: Bool
    var slug: String
    var lang: String
    
    // Creates a new post.
    init(id: Int? = nil, author: User.ID, title: String, text: String,
         textHtml: String, preview: String, categoryID: Category.ID?,
         publishedAt: Date, slug: String, lang: String, isPublished: Bool) {

        self.id = id
        self.author = author
        self.title = title
        self.text = text
        self.textHtml = textHtml
        self.preview = preview
        self.category = categoryID
        self.publishedAt = publishedAt
        self.slug = slug
        self.lang = lang
        self.isPublished = isPublished
    }
}

extension Post: Content {}
extension Post: Parameter {}

// MARK: - Relation

extension Post {
    var parentAuthor: Parent<Post, User> {
        return parent(\.author)
    }
}

extension Post {
    var parentCategory: Parent<Post, Category> {
        return (parent(\.category) ?? nil)!
    }
}
