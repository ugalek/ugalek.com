import Slugify
import Vapor

final class AdminCategoryController {
    func show(request: Request) throws -> Future<View> {
        return try request.view().render("categoryEdit", CategoryCreateView(
            authUser: getAuthUser(session: try request.session()),
            category: CategoryRepository().getByID(on: request, categoryID: try request.parameters.next(Int.self))
        ))
    }

    func create(request: Request) throws -> Future<Response> {
        return try request.content.decode(CategoryForm.self).flatMap { categoryForm in
            var slug = categoryForm.name.slugify()

            let newCategory = try CategoryRepository().slugCount(on: request, categorySlug: slug).map(to: Category.self) { slugCount in
                if slugCount != 0 {
                     slug = slug + "-" + String(slugCount)
                }
                
                return Category(
                    name: categoryForm.name,
                    slug: slug,
                    description: categoryForm.description,
                    logo: categoryForm.logo
                )
            }

            return newCategory.save(on: request).map { _ in
                request.redirect(to: "/categories")
            }
        }
    }

    func update(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Category.self).flatMap { category in
            try request.content.decode(CategoryForm.self).flatMap { categoryForm in
                category.name = categoryForm.name
                category.description = categoryForm.description
                category.logo = categoryForm.logo
                if categoryForm.pslug != categoryForm.slug {
                    category.slug = categoryForm.slug
                }
                
                return category.save(on: request).map { _ in
                    request.redirect(to: "/categories")
                }
            }
            }
    }

    func delete(request: Request) throws -> Future<Response> {
        return try request.parameters.next(Category.self).flatMap { category in
            try category.posts.query(on: request).delete().flatMap { _ in
                category.delete(on: request).map { _ in
                    request.redirect(to: "/categories")
                }
            }
        }
    }
}

struct CategoryCreateView: Encodable {
    var authUser: AuthUser?
    var category: Future<Category>
}
