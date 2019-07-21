import Vapor

struct PostForm: Content {
    var author: Int
    var title: String
    var text: String
    var preview: String
    var category: Int
    var publishedAt: String
    var slug: String
    var pslug: String
    var isPublished: String?
    var lang: String
}
