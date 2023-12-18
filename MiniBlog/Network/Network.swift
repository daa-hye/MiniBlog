//
//  Network.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation
import Moya

enum LslpAPI {
    case join(model: Join)
    case email(model: Email)
    case login(model: Login)
    case refreshToken
    case withdraw
    case post(model: Post)
    case read(cursor: String)
    case readDetail(id: String)
    case comment(id: String, model: Comment)
    case like(id: String)
    case profile
}

extension LslpAPI: TargetType {
    var baseURL: URL {
        URL(string: Lslp.url)!
    }
    
    var path: String {
        switch self {
        case .join:
            return "join"
        case .email:
            return "validation/email"
        case .login:
            return "login"
        case .refreshToken:
            return "refresh"
        case .withdraw:
            return "withdraw"
        case .post, .read:
            return "post"
        case .readDetail(let id):
            return "post/\(id)"
        case .comment(let id, _):
            return "post/\(id)/comment"
        case .like(let id):
            return "post/like/\(id)"
        case .profile:
            return "profile/me"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .join, .email, .login, .post, .comment, .like:
            return .post
        case .refreshToken, .withdraw, .read, .readDetail, .profile:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .join(let data):
            let data = Join(email: data.email, password: data.password, nick: data.nick)
            return .requestJSONEncodable(data)

        case.email(let data):
            let data = Email(email: data.email)
            return .requestJSONEncodable(data)

        case .login(let data):
            let data = Login(email: data.email, password: data.password)
            return .requestJSONEncodable(data)

        case .refreshToken, .withdraw, .readDetail, .like, .profile:
            return .requestPlain

        case .post(let data):
            let imageData = MultipartFormData(provider: .data(data.file), name: "file", fileName: "\(Date()).jpeg", mimeType: "image/jpeg")
            let title = MultipartFormData(provider: .data(Data(data.title.utf8)), name: "title")
            let productId = MultipartFormData(provider: .data(Data("dahye2".utf8)), name: "product_id")
            let width = MultipartFormData(provider: .data(Data(data.width.utf8)), name: "content1")
            let height = MultipartFormData(provider: .data(Data(data.height.utf8)), name: "content2")

            return .uploadMultipart([imageData, title, productId, width, height])

        case .read(let cursor):
            return .requestParameters(
                parameters: ["next" : cursor,
                             "limit" : 15,
                             "product_id" : "dahye2"],
                encoding: URLEncoding.queryString
            )

        case .comment(_, let data):
            let data = Comment(content: data.content)
            return .requestJSONEncodable(data)
        }

    }

    var headers: [String : String]? {
        switch self {
        case .join, .email, .login:
            return [ "Content-Type" : "application/json",
                     "SesacKey" : "\(Lslp.key)"
                   ]

        case .refreshToken:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "SesacKey" : "\(Lslp.key)",
                     "Refresh" : "\(LoginInfo.refreshToken)"
                   ]

        case .withdraw, .read, .readDetail, .like, .profile:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "SesacKey" : "\(Lslp.key)"
                    ]

        case .post:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "Content-Type" : "multipart/form-data",
                     "SesacKey" : "\(Lslp.key)"
             ]

        case .comment:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "Content-Type" : "application/json",
                     "SesacKey" : "\(Lslp.key)"
             ]
            
        }
    }
    
}
