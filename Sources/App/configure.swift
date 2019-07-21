import Authentication
import FluentPostgreSQL
import Leaf
import LingoVapor
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // MARK: Providers
    
    try services.register(LeafProvider())
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    // MARK: Database parameters
    
    let databaseHostname = Environment.get("DB_HOSTNAME")
    let databaseName = Environment.get("DB_DATABASE")
    let databaseUser = Environment.get("DB_USER")
    let databasePassword = Environment.get("DB_PASSWORD")
    let databasePort = Environment.get("DB_PORT")
    
    let psqlConfig = PostgreSQLDatabaseConfig(
        hostname: databaseHostname!,
        port: Int(databasePort!)!,
        username: databaseUser!,
        database: databaseName!,
        password: databasePassword!
        )
    
    let psql = PostgreSQLDatabase(config: psqlConfig)
    services.register(psql)
    
    // MARK: Migrations
    
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: Post.self, database: .psql)
    services.register(migrations)
    
    // MARK: Router
    
    // Register routes to the routers
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    // MARK: - Leaf / View
    
    // Use Leaf for rendering views
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    // Leaf add tags
    services.register { _ -> LeafTagConfig in
        var config = LeafTagConfig.default()
        config.use(Raw(), as: "raw") // #raw(<myVar>) to print it as raw html in leaf vars
        config.use(DateTag(), as: "formdate")
        return config
    }
    
    // MARK: - Lingo
    
    let lingoProvider = LingoProvider(defaultLocale: "en", localizationsDir: "Localizations")
    try services.register(lingoProvider)
    
    // MARK: - Middleware
    
    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    
    let corsConfiguration = CORSMiddleware.Configuration(
        allowedOrigin: .all,
        allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
        allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin, .acceptLanguage]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
}
