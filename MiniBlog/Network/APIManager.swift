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

    struct Response {
        let message: String
        let isSuccess: Bool
    }

    func checkEmailValidation(_ email: String) -> Single<Response> {
        let data = Email(email: email)
        return Single.create { [weak self] single in
            let request = self?.provider.request(.email(model: data)) { result in
                switch result {
                case.success(let value):
                    do {
                        if let message = try? JSONDecoder()
                            .decode(MessageResponse.self, from: value.data)
                            .message {
                            if value.statusCode == 200 {
                                single(.success(Response(message: message, isSuccess: true)))
                            } else {
                                single(.success(Response(message: message, isSuccess: false)))
                            }
                        } else {
//                            single(.faliure())
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                    single(.failure(error))
                }
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }

    func join(email: String, password: String, nick: String) -> Single<Response> {
        let data = Join(email: email, password: password, nick: nick)
        return Single.create { [weak self] single in
            let request = self?.provider.request(.join(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        single(.success(Response(message: "\(nick)님, 가입을 환영해요🎉", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                single(.success(Response(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                    single(.failure(error))
                }
            }

            return Disposables.create {
                request?.cancel()
            }

        }
    }

    func login(email: String, password: String) -> Single<Response> {
        let data = Login(email: email, password: password)
        return Single.create { [weak self] single in
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
                                single(.success(Response(message: "로그인 성공", isSuccess: true)))
                            } else {
                                single(.success(Response(message: "로그인 실패", isSuccess: false)))
                            }
                        }
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                single(.success(Response(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                    single(.failure(error))
                }
            }
            
            return Disposables.create {
                request?.cancel()
            }
        }
    }

    func refreshToken() -> Single<Bool> {
        return Single.create { [weak self] single in
            let request = self?.provider.request(.refreshToken) { result in
                switch result {
                case.success(let value):
                    switch value.statusCode {
                    case 200, 409:
                        single(.success(true))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                single(.success(false))
                            } else {
//                                observer(.failure())
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

    func withdraw() -> Single<Bool> {
        return Single.create { [self] single in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.withdraw) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        return single(.success(true))
                    case 419:
                        self.refreshToken().subscribe { [self] refresh in
                            if refresh {
                                self.withdraw()
                                    .subscribe(single)
                                    .disposed(by: disposeBag)
                            } else {
                                single(.success(false))
                            }
                        }
                        .disposed(by: disposeBag)
                    default:
                        single(.success(false))
                    }
                case.failure(let error):
                    print(error.localizedDescription)
                    single(.failure(error))
                }

            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
