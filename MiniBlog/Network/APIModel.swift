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
    let file: Data
    let productId: String

    enum CodingKeys: String, CodingKey {
        case title
        case content
        case file
        case productId = "product_id"
    }
}

struct Read {
    let next: String?
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

struct ReadResponse: Decodable {
    let data: [ReadData]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct ReadData: Decodable {
    let likes: [String]
    let image: [String]
    //let hashTags: [String]
    let creator: Creator
    let time: String
    let title: String?
    let content: String?
    let productId: String?

    enum CodingKeys: String, CodingKey {
        case likes
        case image
        case creator
        case time
        case title
        case content
        case productId = "product_id"
    }
}

struct Creator: Decodable {
    let nick: String
//    let profile: String
}

struct MessageResponse: Decodable {
    let message: String
}

struct Response {
    let message: String
    let isSuccess: Bool
}
