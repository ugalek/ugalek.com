import Authentication
import Vapor

final class UserRoutes: RouteCollection {
    
    func boot(router: Router) throws {
        
        // register
        do {
            let controller = AuthController()
            router.get("register", use: controller.showRegister)
            router.post("register", use: controller.register)
        }
        
        // login
        do {
            let controller = AuthController()
            router.get("login", use: controller.login)
            router.post(LoginForm.self, at: "login", use: controller.login)
        }
        
        // logout
        do {
            let controller = AuthController()
            router.get("logout", use: controller.logout)
        }
        
        // profile
        do {
            let controller = AuthController()
            let protectedRouter = router.grouped(RedirectMiddleware<User>(path: "/login"))
            protectedRouter.get("profile", use: controller.profile)
        }
        
        // posts
        do {
            let controller = PostController()
            let protectedRouter = router.grouped(RedirectMiddleware<User>(path: "/login"))
            protectedRouter.get("post", use: controller.showCreate)
            protectedRouter.get("post", Int.parameter, use: controller.showEdit)
            protectedRouter.post("post", use: controller.create)
            protectedRouter.post("post", Post.parameter, "update", use: controller.update)
        }
    }
}
