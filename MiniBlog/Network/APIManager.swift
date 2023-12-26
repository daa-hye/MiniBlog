//
//  APIManager.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import UIKit

import Moya
import RxSwift
import Kingfisher

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
                            //observer(.faliure())
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
                                observer(.failure(MoyaError.statusCode(value)))
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
                            if let responseData = try? JSONDecoder()
                                .decode(LoginResponse.self, from: value.data) {
                                LoginInfo.id = responseData.id
                                LoginInfo.email = data.email
                                LoginInfo.password = data.password
                                LoginInfo.token = responseData.token
                                LoginInfo.refreshToken = responseData.refreshToken
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
                                observer(.failure(MoyaError.statusCode(value)))
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

    func refreshToken() -> Single<Void> {
        return Single.create { observer in
            let request = self.provider.request(.refreshToken) { result in
                switch result {
                case.success(let value):
                    switch value.statusCode {
                    case 200:
                        if let token = try? JSONDecoder().decode(TokenResponse.self, from: value.data).token {
                            LoginInfo.token = token
                        }
                        observer(.success(()))
                    case 409:
                        observer(.success(()))
                    case 418:
                        let vc = SignInViewController()
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        guard let sceneDelegate else { return }

                        sceneDelegate.window?.rootViewController = vc
                    default:
                        observer(.failure(MoyaError.statusCode(value)))
                    }
                case .failure(let error):
                    observer(.failure(error))
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
                        self.refreshToken()
                            .catch { _ in .error(MoyaError.statusCode(value))  }
                            .flatMap { _ in
                                self.withdraw()
                            }
                            .subscribe(observer)
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
            print("#111",data)
            let request = self.provider.request(.post(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(Response(message: "성공", isSuccess: true)))
                    case 419:
                        self.refreshToken()
                            .catch { _ in .error(MoyaError.statusCode(value))  }
                            .flatMap { _ in
                                self.post(data)
                            }
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Response(message: message, isSuccess: false)))
                            } else {
                                observer(.failure(MoyaError.statusCode(value)))
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

    func read(cursor: String) -> Single<ReadResponse> {
        return Single.create { observer in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.read(cursor: cursor)) { result in
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
                            observer(.failure(MoyaError.statusCode(value)))
                        }
                    case 419:
                        self.refreshToken()
                            .catch { _ in .error(MoyaError.statusCode(value))  }
                            .flatMap { _ in
                                self.read(cursor: cursor)
                            }
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                    default:
                        observer(.failure(MoyaError.statusCode(value)))
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

    func read(id: String) -> Single<ReadDetail> {
        return Single.create { observer in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.readDetail(id: id)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        do {
                            let data = try JSONDecoder()
                                .decode(ReadDetail.self, from: value.data)

                            observer(.success(data))
                        } catch {
                            print(error)
                            observer(.failure(error))
                        }
                    case 419:
                        self.refreshToken()
                            .catch { _ in .error(MoyaError.statusCode(value))  }
                            .flatMap { _ in
                                self.read(id: id)
                            }
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                    default:
                        observer(.failure(MoyaError.statusCode(value)))
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

    func readUser(id:String, cursor: String) -> Single<ReadResponse> {
        return Single.create { observer in
            let disposeBag = DisposeBag()
            let request = self.provider.request(.readUser(id: id, cursor: cursor)) { result in
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
                            observer(.failure(MoyaError.statusCode(value)))
                        }
                    case 419:
                        self.refreshToken()
                            .catch { _ in .error(MoyaError.statusCode(value))  }
                            .flatMap { _ in
                                self.read(cursor: cursor)
                            }
                            .subscribe(observer)
                            .disposed(by: disposeBag)
                    default:
                        observer(.failure(MoyaError.statusCode(value)))
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

    func like(id: String) -> Single<Bool> {
        return Single.create { observer in
            let request = self.provider.request(.like(id: id)) { result in
                switch result {
                case .success(let value):
                    do {
                        let data = try JSONDecoder()
                            .decode(LikeResponse.self, from: value.data)
                        observer(.success(data.isLiked))
                    } catch {
                        print(error)
                        observer(.failure(MoyaError.statusCode(value)))
                    }
                case .failure(let error):
                    observer(.failure(MoyaError.underlying(error, nil)))
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func comment(id: String, model: Comment) -> Single<Response> {
        Single.create { observer in
            let request = self.provider.request(.comment(id: id, model: model)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(Response(message: "성공", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(Response(message: message, isSuccess: false)))
                            } else {
                                observer(.failure(MoyaError.statusCode(value)))
                            }
                        }

                    }

                case.failure(let error):
                    observer(.failure(error))
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    func getComments(_ id: String) -> Single<[Comments]> {
        self.read(id: id)
            .map { $0.comments }
    }

    func getLikes(_ id: String) -> Single<Int> {
        self.read(id: id)
            .map { $0.likes.count }
    }

    func profile() -> Single<Profile> {
        Single.create { observer in
            let disposeBag = DisposeBag()

            let request = self.provider.request(.profile) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        do {
                            let data = try JSONDecoder()
                                .decode(Profile.self, from: value.data)
                            LoginInfo.profile = data.profile?.absoluteString ?? Lslp.profile
                            observer(.success(data))
                        } catch {
                            print(error)
                            observer(.failure(error))
                        }

                    case 419:
                        self.refreshToken()
                            .catch{ error in
                                .error(error)
                            }
                            .flatMap({ _ in
                                self.profile()
                            })
                            .subscribe(observer)
                            .disposed(by: disposeBag)

                    default:
                        observer(.failure(MoyaError.statusCode(value)))
                    }

                case .failure(let error):
                    observer(.failure(error))
                    print(error.localizedDescription)
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    let imageDownloadRequest = AnyModifier { request in
        var requestBody = request
        requestBody.setValue(LoginInfo.token, forHTTPHeaderField: "Authorization")
        requestBody.setValue(Lslp.key, forHTTPHeaderField: "SesacKey")
        return requestBody
    }

}
