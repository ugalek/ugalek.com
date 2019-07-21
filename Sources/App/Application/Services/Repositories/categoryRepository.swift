import FluentPostgreSQL
import FluentSQL
import Vapor

struct CategoryRepository {
    func findAll(on request: Request) throws -> Future<[Category]> {
        return Category.query(on: request).all()
    }
    
    func getByID(on request: Request, categoryID: Int) throws -> Future<Category> {
        return Category.find(categoryID, on: request).unwrap(or: Abort(BaseRepository().notFoundErr(reason: "Category with ID '\(categoryID)'")))
    }
    
    func getBySlug(on request: Request, categorySlug: String) throws -> Future<Category?> {
        return Category.query(on: request)
            .filter(\.slug  == categorySlug)
            .first()
    }
    
    func slugCount(on request: Request, categorySlug: String) throws -> Future<Int> {
        return Category.query(on: request)
            .filter(\.slug =~ categorySlug)
            .count()
    }
    
    
    func getCategories(on request: Request) throws -> Future<[CardOfCats]> {
        var categoryArr = [Category]()
        var cardOfCats = [CardOfCats]()
        var i = 0
        var line = 1
        return Category.query(on: request).all().map(to: [CardOfCats].self) { (cats) -> [CardOfCats] in
            
            for c in cats {
                if i == 3 {
                    cardOfCats.append(CardOfCats(categoryArr: categoryArr, line: line))
                    categoryArr = [Category]()
                    categoryArr.append(c)
                    i = 1
                    line += 1
                } else {
                    i += 1
                    categoryArr.append(c)
                }
            }
            cardOfCats.append(CardOfCats(categoryArr: categoryArr, line: line))
            
            return cardOfCats
        }
    }
}

struct CardOfCats: Content {
    var categoryArr: [Category]
    var line: Int
    init(categoryArr: [Category], line: Int) {
        self.categoryArr = categoryArr
        self.line = line
    }
}
