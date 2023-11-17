import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)

    app.migrations.add(CreateTodo())
    
    app.migrations.add(CreateUser())
    
    // 运行迁移
    try await app.autoMigrate().get()
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))


    // register routes
    try routes(app)
}
