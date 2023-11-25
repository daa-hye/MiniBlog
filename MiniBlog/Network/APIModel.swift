//
//  APIModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation

struct Join: Encodable {
    let email: String
    let password: String
    let nick: String
}

struct Email: Encodable {
    let email: String
}

struct Login: Encodable {
    let email: String
    let password: String
}

struct Post: Encodable {
    let title: String
    let content: String
    let file: [Data]
    let productId: String
}

struct JoinResponse: Decodable {
    let email: String
    let nick :String
}

struct LoginResponse: Decodable {
    let token: String
    let refreshToken: String
}

struct MessageResponse: Decodable {
    let message: String
}
