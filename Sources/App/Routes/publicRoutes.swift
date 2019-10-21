import Vapor

final class PublicRoutes: RouteCollection {
    
    func boot(router: Router) throws {
        
        // home page
        do {
            let controller = HomeController()
            router.get("/", use: controller.index)
        }
        
        // posts
        do {
            let controller = PostController()
            router.get("posts", use: controller.index)
            router.get("posts", String.parameter, use: controller.detail)
        }
        
        // categories
        do {
            let controller = CategoryController()
            router.get("categories", use: controller.index)
        }
        
        // posts in category
        do {
            let controller = CategoryController()
            router.get("categories", String.parameter, use: controller.listOfPostsOnCategory)
        }
        
        // searching
        do {
            let controller = PostController()
            router.get("search", use: controller.index)
        }
        
        // language
        do {
            let controller = HomeController()
            router.get("lang", use: controller.setLanguage)
        }

        // kaniotte
        do {
            let controller = KaniotteController()
            router.get("kaniotte", use: controller.index)
        }
    }
}
