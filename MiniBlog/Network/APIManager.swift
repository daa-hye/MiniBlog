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

    func checkEmailValidation(_ data: Email) -> Single<Response> {
        return Single.create { observer in
            let request = self.provider.request(.email(model: data)) { result in
                switch result {
                case.success(let value):
                    do {
                        if let message = try? JSONDecoder()
                            .decode(MessageResponse.self, from: value.data)
                            .message {
                            if value.statusCode == 200 {
                                observer(.success(Response(message: message, isSuccess: true)))
                            } else {
                                observer(.success(Response(message: message, isSuccess: false)))
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
                request.cancel()
            }
        }
    }

    func join(_ data: Join) -> Single<Response> {
        return Single.create { observer in
            let request = self.provider.request(.join(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(Response(message: "\(data.nick)님, 가입을 환영해요🎉", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Response(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                request.cancel()
            }

        }
    }

    func login(_ data: Login) -> Single<Response> {
        return Single.create { observer in
            let request = self.provider.request(.login(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        do {
                            if let token = try? JSONDecoder()
                                .decode(LoginResponse.self, from: value.data) {
                                LoginInfo.email = data.email
                                LoginInfo.password = data.password
                                LoginInfo.token = token.token
                                LoginInfo.refreshToken = token.refreshToken
                                observer(.success(Response(message: "로그인 성공", isSuccess: true)))
                            } else {
                                observer(.success(Response(message: "로그인 실패", isSuccess: false)))
                            }
                        }
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Response(message: message, isSuccess: false)))
                            } else {

                            }
                        }
                    }

                case .failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }

    func refreshToken() -> Single<Bool> {
        return Single.create { observer in
            let request = self.provider.request(.refreshToken) { result in
                switch result {
                case.success(let value):
                    switch value.statusCode {
                    case 200, 409:
                        observer(.success(true))
                    default:
                        observer(.success(false))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request.cancel()
            }

        }
    }

    func withdraw() -> Single<Bool> {
        return Single.create { observer in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.withdraw) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        return observer(.success(true))
                    case 419:
                        self.refreshToken().subscribe { refresh in
                            if refresh {
                                self.withdraw()
                                    .subscribe(observer)
                                    .disposed(by: disposeBag)
                            } else {
                                observer(.success(false))
                            }
                        }
                        .disposed(by: disposeBag)
                    default:
                        observer(.success(false))
                    }
                case.failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }

            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func post(_ data: Post) -> Single<Response> {
        let disposeBag = DisposeBag()

        return Single.create { observer in
            let request = self.provider.request(.post(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(Response(message: "성공", isSuccess: true)))
                    case 419:
                        self.refreshToken()
                            .subscribe { refresh in
                                if refresh {
                                    self.post(data)
                                    .subscribe(observer)
                                    .disposed(by: disposeBag)
                                } else {
                                    observer(.success(Response(message: "실패", isSuccess: false)))
                                }
                            }
                            .disposed(by: disposeBag)
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Response(message: message, isSuccess: false)))
                            } else {
//                                observer(.failure())
                            }
                        }
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func read() -> Single<ReadResponse> {
        return Single.create { observer in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.read) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        do {
                            let data = try JSONDecoder()
                                .decode(ReadResponse.self, from: value.data)
                            observer(.success(data))
                        } catch {
                            print(error)
                            observer(.success(ReadResponse(data: [], nextCursor: "")))
                        }
                    case 419:
                        self.refreshToken()
                            .subscribe { refresh in
                            if refresh {
                                self.read()
                                    .subscribe(observer)
                                    .disposed(by: disposeBag)
                            } else {
                                observer(.success(ReadResponse(data: [], nextCursor: "")))
                            }
                        }
                        .disposed(by: disposeBag)
                    default:
                        observer(.success(ReadResponse(data: [], nextCursor: "")))
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    observer(.failure(error))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

}
