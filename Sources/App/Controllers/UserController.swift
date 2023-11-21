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
    
    func create(req: Request) throws -> EventLoopFuture<ResponseData<User>> {
        let userRequest = try req.content.decode(UserRequest.self)
        print("Received user request: \(userRequest)")

        let username = generateRandomUsername()
        let avatar = "http://e.hiphotos.baidu.com/image/pic/item/a1ec08fa513d2697e542494057fbb2fb4316d81e.jpg"
        let user = User(email: userRequest.email, username: username, password: userRequest.password, avatar: avatar, age: 23)

        return user.save(on: req.db).flatMap { savedUser in
            return req.eventLoop.makeSucceededFuture(ResponseData(code: 200, msg: "Success", data: user))
        }.flatMapErrorThrowing { error in
            throw Abort(.badRequest, reason: "Error creating user: \(error)")
        }
    }



    private func generateRandomUsername() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz"
        return String((0..<3).map{ _ in letters.randomElement()! })
    }
    
    
    func getAll(req: Request) throws -> EventLoopFuture<ResponseData<[User]>> {
        return User.query(on: req.db).all().map { users in
            ResponseData(code: 200, msg: "Success", data: users)
        }.flatMapErrorThrowing { error in
            throw Abort(.internalServerError, reason: "Failed to retrieve users: \(error)")
        }
    }


    func getById(req: Request) throws -> EventLoopFuture<ResponseData<User>> {
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .map { user in
                ResponseData(code: 200, msg: "Success", data: user)
            }.flatMapErrorThrowing { error in
                if error is AbortError {
                    throw error
                } else {
                    throw Abort(.internalServerError, reason: "Failed to retrieve user: \(error)")
                }
            }
    }


    func update(req: Request) throws -> EventLoopFuture<ResponseData<User>> {
        let updatedUser = try req.content.decode(User.self)
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound)).flatMap { user in
                user.email = updatedUser.email
                user.username = updatedUser.username
                user.password = updatedUser.password
                user.avatar = updatedUser.avatar
                user.age = updatedUser.age
                return user.save(on: req.db).map {
                    ResponseData(code: 200, msg: "User updated successfully", data: user)
                }
            }.flatMapErrorThrowing { error in
                if error is AbortError {
                    throw error
                } else {
                    throw Abort(.internalServerError, reason: "Failed to update user: \(error)")
                }
            }
    }


    func delete(req: Request) throws -> EventLoopFuture<ResponseData<HTTPStatus>> {
        return User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { user in
                user.delete(on: req.db)
            }.map {
                ResponseData(code: 200, msg: "User deleted successfully", data: .ok)
            }.flatMapErrorThrowing { error in
                if error is AbortError {
                    throw error
                } else {
                    throw Abort(.internalServerError, reason: "Failed to delete user: \(error)")
                }
            }
    }


}
public struct ResponseData<T: Codable>: Codable {
    var code: Int
    var msg: String
    var data: T?
}

// 确保 ResponseData 遵循 ResponseEncodable
extension ResponseData: ResponseEncodable {
    public func encodeResponse(for request: Request) -> EventLoopFuture<Response> {
        do {
            let response = try Response(
                status: .ok,
                headers: ["Content-Type": "application/json"],
                body: .init(data: JSONEncoder().encode(self))
            )
            return request.eventLoop.makeSucceededFuture(response)
        } catch {
            return request.eventLoop.makeFailedFuture(error)
        }
    }
  
}
enum UserError: Error {
    case notFound
    case invalidInput(String)
    case serverError(String)
    // 更多错误类型...
}

extension UserError: AbortError {
    var status: HTTPStatus {
        switch self {
        case .notFound:
            return .notFound
        case .invalidInput:
            return .badRequest
        case .serverError:
            return .internalServerError
        // 更多映射...
        }
    }

    var reason: String {
        switch self {
        case .notFound:
            return "User not found."
        case .invalidInput(let message):
            return "Invalid input: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        // 更多原因...
        }
    }
}