import Vapor

struct CategoryForm: Content {
    var name: String
    var description: String
    var logo: String
    var slug: String
    var pslug: String
}
