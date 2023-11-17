//
//  File.swift
//  
//
//  Created by hyd on 2023/11/17.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "username")
    var username: String

    @Field(key: "password")
    var password: String

    @Field(key: "avatar")
    var avatar: String

    @Field(key: "age")
    var age: Int

    init() {}

    init(id: UUID? = nil, email: String, username: String, password: String, avatar: String, age: Int) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.avatar = avatar
        self.age = age
    }
}
