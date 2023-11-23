import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import Mailgun
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
    
    app.middleware.use(ErrorMiddleware { req, error in
        let status: HTTPStatus
        let message: String

        if let abortError = error as? AbortError {
            status = abortError.status
            message = abortError.reason
        } else {
            status = .internalServerError
            message = "Internal Server Error"
        }

        let responseData = ResponseData<EmptyData>(code: Int(status.code), msg: message, data: nil)

        // 创建 Response 对象
        let response = Response(status: status)
        do {
            // 尝试编码 responseData
            try response.content.encode(responseData, as: .json)
        } catch {
            // 如果编码失败，设置响应为内部服务器错误
            response.status = .internalServerError
            response.body = .init(string: "Internal Server Error")
        }
        return response
    })
    
    app.mailgun.configuration = .init(apiKey: "ed59591e058d0e19410cf5bb0466428f-5d2b1caa-214752ef")

    app.mailgun.defaultDomain = .ClockCat
    
    // register routes
    try routes(app)
}
struct EmptyData: Codable {}

extension MailgunDomain {
    static var ClockCat: MailgunDomain { .init("mail.clockcat,site", .us) }
    static var iTimes: MailgunDomain { .init("itimes.me", .us) }

}
