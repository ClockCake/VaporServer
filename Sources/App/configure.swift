import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import Mailgun
import Crypto
// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder

    app.databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite)
    
    app.migrations.add(CreateUser())
    

    
    // 运行迁移
    try await app.autoMigrate().get()
    
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    
    /// 网络中间件设置
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
    
    app.mailgun.configuration = .init(apiKey: decodeBase64("ZWQ1OTU5MWUwNThkMGUxOTQxMGNmNWJiMDQ2NjQyOGYtNWQyYjFjYWEtMjE0NzUyZWY=") ?? "")

    app.mailgun.defaultDomain = .ClockCat
    
    // register routes
    try routes(app)
}

private func decodeBase64(_ base64String: String) -> String? {
    // 尝试将Base64字符串转换为Data
    guard let data = Data(base64Encoded: base64String) else {
        print("Error: String is not Base64 encoded")
        return nil
    }

    // 将Data转换为String
    return String(data: data, encoding: .utf8)
}
struct EmptyData: Codable {}

extension MailgunDomain {
    static var ClockCat: MailgunDomain { .init("mail.clockcat.site", .us) }
    static var iTimes: MailgunDomain { .init("itimes.me", .us) }

}
