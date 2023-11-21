//
//  LoginInfo.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/22/23.
//

import Foundation

enum LoginInfo {

    enum Key: String {
        case email
        case password
        case nickname
        case token
        case refreshToken
    }

    @UserDafaultsManager(key: Key.email.rawValue, defaultValue: "?")
    static var email

    @UserDafaultsManager(key: Key.password.rawValue, defaultValue: "?")
    static var password

    @UserDafaultsManager(key: Key.nickname.rawValue, defaultValue: "손님")
    static var nickname

    @UserDafaultsManager(key: Key.token.rawValue, defaultValue: "0")
    static var token

    @UserDafaultsManager(key: Key.refreshToken.rawValue, defaultValue: "0")
    static var refreshToken

}