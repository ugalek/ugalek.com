import Vapor
import Authentication

public func routes(_ router: Router) throws {
    
    let root = router.grouped(User.authSessionsMiddleware())
    try root.register(collection: PublicRoutes())
    try root.register(collection: UserRoutes())
    try root.register(collection: AdminRoutes())

}
