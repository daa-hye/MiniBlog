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
    let file: Data
}

struct JoinResponse: Decodable {
    let email: String
    let nick :String
}

struct LoginResponse: Decodable {
    let id: String
    let token: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case token
        case refreshToken
    }
}

struct ReadResponse: Decodable {
    let data: [ReadData]
    let nextCursor: String

    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}

struct ReadData: Decodable, Hashable {
    let likes: [String]
    let image: URL
    //let hashTags: [String]
    let creator: Creator
    let time: String
    let title: String?
    let content: String?
    let productId: String?
    let id: String

    enum CodingKeys: String, CodingKey {
        case likes
        case image
        case creator
        case time
        case title
        case content
        case productId = "product_id"
        case id = "_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.likes = try container.decode([String].self, forKey: .likes)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.time = try container.decode(String.self, forKey: .time)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        self.productId = try container.decodeIfPresent(String.self, forKey: .productId)
        self.id = try container.decode(String.self, forKey: .id)

        let imagePath = try container.decode([String].self, forKey: .image).first
        if let imagePath = imagePath, let url = URL(string: "\(Lslp.url)\(imagePath)") {
            self.image = url
        } else {
            throw DecodingError.valueNotFound(URL.self, .init(codingPath: decoder.codingPath, debugDescription: "value not found"))
        }
    }
}

struct Creator: Decodable, Hashable {
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
