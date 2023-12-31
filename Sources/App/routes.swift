import Fluent
import Vapor
import Mailgun
func routes(_ app: Application) throws {
    let userController = UserController()

    app.post("users", use: userController.create)
    app.get("users", use: userController.getAll)
    app.get("users", ":userID", use: userController.getById)
    app.put("users", ":userID", use: userController.update)
    app.delete("users", ":userID", use: userController.delete)
    app.post("verification", use: userController.register)
    
    app.get("hello") { req -> EventLoopFuture<View> in
        return req.view.render("hello", ["name": "Leaf"])
    }


}
