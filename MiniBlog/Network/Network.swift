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
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .join, .email, .login:
            return .post
        case .refreshToken, .withdraw:
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
        }
    }

    
}
