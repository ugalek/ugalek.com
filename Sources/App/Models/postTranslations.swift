import FluentPostgreSQL
import Foundation
import Vapor

// A Translations.
final class PostTranslation: PostgreSQLModel {
    
    static let entity = "translations"
    
    private enum CodingKeys: String, CodingKey {
        case id
        case original
        case translation
    }
    
    var id: Int?
    var original: Post.ID
    var translation: Post.ID
    
    // Creates a new translations.
    init(id: Int? = nil, original: Post.ID, translation: Post.ID) {
        self.id = id
        self.original = original
        self.translation = translation
    }
}

extension PostTranslation: Content {}
extension PostTranslation: Parameter {}
