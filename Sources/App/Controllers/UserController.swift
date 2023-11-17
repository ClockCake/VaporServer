//
//  File.swift
//  
//
//  Created by hyd on 2023/11/17.
//

import Vapor

struct UserRequest: Content {
    let email: String
    let password: String
}
class UserController {
    
    func create(req: Request) throws -> EventLoopFuture<User> {
        do {
            let userRequest = try req.content.decode(UserRequest.self)
            // 添加日志输出
            print("Received user request: \(userRequest)")

            let username = generateRandomUsername()
            let avatar = "http://e.hiphotos.baidu.com/image/pic/item/a1ec08fa513d2697e542494057fbb2fb4316d81e.jpg"
            let user = User(email: userRequest.email, username: username, password: userRequest.password, avatar: avatar, age: 23)

            return user.save(on: req.db).map { user }
        } catch {
            print("Error decoding request: \(error)")
            throw error
        }
    }

    private func generateRandomUsername() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<3).map{ _ in letters.randomElement()! })
    }

    func getAll(req: Request) throws -> EventLoopFuture<[User]> {
        User.query(on: req.db).all()
    }

    func getById(req: Request) throws -> EventLoopFuture<User> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func update(req: Request) throws -> EventLoopFuture<User> {
        let updatedUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
                user.email = updatedUser.email
                user.username = updatedUser.username
                user.password = updatedUser.password
                user.avatar = updatedUser.avatar
                user.age = updatedUser.age
                return user.save(on: req.db).map { user }
            }
    }

    func delete(req: Request) throws -> EventLoopFuture<HTTPStatus> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.delete(on: req.db)
            }.transform(to: .ok)
    }
}
