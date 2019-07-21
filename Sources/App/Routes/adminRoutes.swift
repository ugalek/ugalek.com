import Authentication
import Vapor

final class AdminRoutes: RouteCollection {
    func boot(router: Router) throws {
        
        // users
        do {
            let controller = AdminUserController()
            let admin = router.grouped(RedirectMiddleware<User>(path: "/login")).grouped(AdminMiddleware())
            
            admin.get("users", use: controller.index)
            admin.post("users", use: controller.create)
            admin.post("users", User.parameter, "update", use: controller.update)
            admin.post("users", User.parameter, "delete", use: controller.delete)

        }
        
        // categories
        do {
            let controller = AdminCategoryController()
            let admin = router.grouped(RedirectMiddleware<User>(path: "/login")).grouped(AdminMiddleware())
            admin.get("category", Int.parameter, use: controller.show)
            admin.post("category", use: controller.create)
            admin.post("category", Category.parameter, "update", use: controller.update)
            admin.post("category", Category.parameter, "delete", use: controller.delete)
        }
    }
}
