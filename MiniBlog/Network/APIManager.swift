//
//  APIManager.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation
import Moya
import RxSwift

class APIManager {

    static let shared = APIManager()
    private init() {}

    let provider = MoyaProvider<LslpAPI>()

    func makeObservable() -> Observable<Int> {
        return Observable.just(1)
    }

    struct Result {
        let message: String
        let isSuccess: Bool
    }

    func checkEmailValidation(_ email: String) -> Single<Result> {
        let data = Email(email: email)
        return Single.create { [weak self] observer in
            let request = self?.provider.request(.email(model: data)) { result in
                switch result {
                case.success(let value):
                    do {
                        if let message = try? JSONDecoder()
                            .decode(MessageResponse.self, from: value.data)
                            .message {
                            if value.statusCode == 200 {
                                observer(.success(Result(message: message, isSuccess: true)))
                            } else {
                                observer(.success(Result(message: message, isSuccess: false)))
                            }
                        } else {
//                            observer(.faliure())
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }

    func join(email: String, password: String, nick: String) -> Single<Result> {
        let data = Join(email: email, password: password, nick: nick)
        return Single.create { [weak self] observer in
            let request = self?.provider.request(.join(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(Result(message: "\(nick)님, 가입을 환영해요🎉", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Result(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request?.cancel()
            }

        }
    }

    func login(email: String, password: String) -> Single<Result> {
        let data = Login(email: email, password: password)
        return Single.create { [weak self] observer in
            let request = self?.provider.request(.login(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        do {
                            if let token = try? JSONDecoder()
                                .decode(LoginResponse.self, from: value.data) {
                                LoginInfo.email = email
                                LoginInfo.password = password
                                LoginInfo.token = token.token
                                LoginInfo.refreshToken = token.refreshToken
                                observer(.success(Result(message: "로그인 성공", isSuccess: true)))
                            } else {

                            }
                        }
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Result(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }

    func refreshToken() -> Single<Result> {
        return Single.create { [weak self] observer in
            let request = self?.provider.request(.refreshToken) { result in
                switch result {
                case.success(let value):
                    switch value.statusCode {
                    case 200, 409:
                        observer(.success(Result(message: "성공", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Result(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request?.cancel()
            }
            
        }
    }
}
