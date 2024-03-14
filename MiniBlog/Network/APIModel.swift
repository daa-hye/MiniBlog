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
    let width: String
    let height: String
    let hashtag: String
}

struct Comment: Encodable {
    let content: String
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
    let image: URL
    let id: String
    let width: String?
    let height: String?

    enum CodingKeys: String, CodingKey {
        case image
        case width = "content1"
        case height = "content2"
        case id = "_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.id = try container.decode(String.self, forKey: .id)

        let imagePath = try container.decode([String].self, forKey: .image).first
        if let imagePath = imagePath, let url = URL(string: "\(Lslp.url)\(imagePath)") {
            self.image = url
        } else {
            throw DecodingError.valueNotFound(URL.self, .init(codingPath: decoder.codingPath, debugDescription: "value not found"))
        }
    }

}

struct ReadDetail: Decodable, Hashable {
    let likes: [String]
    let image: URL
    let comments: [Comments]
    let hashTags: [String]
    let creator: Creator
    let time: String
    let title: String
    let width: String?
    let height: String?
    let id: String

    enum CodingKeys: String, CodingKey {
        case likes
        case image
        case creator
        case comments
        case hashTags
        case time
        case title
        case width = "content1"
        case height = "content2"
        case id = "_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.likes = try container.decode([String].self, forKey: .likes)
        self.creator = try container.decode(Creator.self, forKey: .creator)
        self.comments = try container.decode([Comments].self, forKey: .comments)
        self.hashTags = try container.decode([String].self, forKey: .hashTags)
        self.time = try container.decode(String.self, forKey: .time)
        self.title = try container.decode(String.self, forKey: .title)
        self.width = try container.decodeIfPresent(String.self, forKey: .width)
        self.height = try container.decodeIfPresent(String.self, forKey: .height)
        self.id = try container.decode(String.self, forKey: .id)

        let imagePath = try container.decode([String].self, forKey: .image).first
        if let imagePath = imagePath, let url = URL(string: "\(Lslp.url)\(imagePath)") {
            self.image = url
        } else {
            throw DecodingError.valueNotFound(URL.self, .init(codingPath: decoder.codingPath, debugDescription: "value not found"))
        }
    }
    
}

struct Comments: Decodable, Hashable {
    let id: String
    let content: String
    let time: String
    let creator: Creator

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case content
        case time
        case creator
    }
}

struct Creator: Decodable, Hashable {
    let id: String
    let nick: String
    let profile: URL?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case nick
        case profile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.nick = try container.decode(String.self, forKey: .nick)

        let profilePath = try container.decodeIfPresent(String.self, forKey: .profile)
        if let profilePath = profilePath, let url = URL(string: "\(Lslp.url)\(profilePath)") {
            self.profile = url
        } else if let url = URL(string: "\(Lslp.profile)") {
            self.profile = url
        } else {
            self.profile = nil
        }
    }

}

struct Profile: Decodable {
    let posts: [String]
    let followers: [Creator]
    let following: [Creator]
    let id: String
    let email: String
    let nick: String
    let phoneNum: String?
    let birthDay: String?
    let profile: URL?

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case posts
        case followers
        case following
        case email
        case nick
        case phoneNum
        case birthDay
        case profile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.posts = try container.decode([String].self, forKey: .posts)
        self.followers = try container.decode([Creator].self, forKey: .followers)
        self.following = try container.decode([Creator].self, forKey: .following)
        self.email = try container.decode(String.self, forKey: .email)
        self.nick = try container.decode(String.self, forKey: .nick)
        self.phoneNum = try container.decodeIfPresent(String.self, forKey: .phoneNum)
        self.birthDay = try container.decodeIfPresent(String.self, forKey: .birthDay)

        let profilePath = try container.decodeIfPresent(String.self, forKey: .profile)
        if let profilePath = profilePath, let url = URL(string: "\(Lslp.url)\(profilePath)") {
            self.profile = url
        } else if let url = URL(string: "\(Lslp.profile)") {
            self.profile = url
        } else {
            self.profile = nil
        }
    }
}

struct LikeResponse: Decodable {
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case isLiked = "like_status"
    }
}

struct TokenResponse: Decodable {
    let token: String
}

struct MessageResponse: Decodable {
    let message: String
}

struct FollowResponse: Decodable {
    let user: String
    let following: String
    let followingStatus: Bool

    enum CodingKeys: String, CodingKey {
        case user
        case following
        case followingStatus = "following_status"
    }
}

struct Response {
    let message: String
    let isSuccess: Bool
}
