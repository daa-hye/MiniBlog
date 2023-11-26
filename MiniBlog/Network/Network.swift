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
    case read(model: Read)
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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .join, .email, .login, .post:
            return .post
        case .refreshToken, .withdraw, .read:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .join(let data):
            let data = Join(email: data.email, password: data.password, nick: data.nick)
            return .requestJSONEncodable(data)

        case.email(model: let data):
            let data = Email(email: data.email)
            return .requestJSONEncodable(data)

        case .login(let data):
            let data = Login(email: data.email, password: data.password)
            return .requestJSONEncodable(data)

        case .refreshToken, .withdraw:
            return .requestPlain

        case .post(let data):
            let data = Post(title: data.title, content: data.content, file: data.file, productId: data.productId)
            return .requestJSONEncodable(data)

        case .read(let data):
            let data = Read(next: data.next, productId: data.productId)
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
        case .withdraw:
            return [ "Authorization" : "\(LoginInfo.token)",
                            "SesacKey" : "\(Lslp.key)"
                    ]

        case .post:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "Content-Type" : "multipart/form-data",
                     "SesacKey" : "\(Lslp.key)"
             ]

        case .read:
            return [ "Authorization" : "\(LoginInfo.token)",
                     "SesacKey" : "\(Lslp.key)"
             ]
        }
    }

    
}
