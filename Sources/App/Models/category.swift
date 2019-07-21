import FluentPostgreSQL
import Vapor

// A category.
final class Category: DatabaseModel {
    
    static let entity = "categories"
    static let descriptionLength = 250
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case slug
        case description
        case logo
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var id: Int?
    var name: String
    var slug: String
    var description: String
    var logo: String
    var createdAt: Date?
    var updatedAt: Date?
    
    // Creates a new category.
    init(id: Int? = nil, name: String, slug: String, description: String, logo: String) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.logo = logo
    }
}

extension Category: Content {}
extension Category: Parameter {}

extension Category {
    var posts: Children<Category, Post> {
        return children(\.category)
    }
}
