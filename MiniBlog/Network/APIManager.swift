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

    struct EmailValidation {
        let message: String
        let isValid: Bool
    }

    func checkEmailValidation(_ email: String) -> Single<EmailValidation> {
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
                                observer(.success(EmailValidation(message: message, isValid: true)))
                            } else {
                                observer(.success(EmailValidation(message: message, isValid: false)))
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

    struct JoinResult {
        let message: String
        let isSuccess: Bool
    }

    func join(email: String, password: String, nick: String) -> Single<JoinResult> {
        let data = Join(email: email, password: password, nick: nick)
        return Single.create { [weak self] observer in
            let request = self?.provider.request(.join(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer(.success(JoinResult(message: "", isSuccess: true)))
                    default:
                        do {
                            if let message = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer(.success(JoinResult(message: message, isSuccess: false)))
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

}
