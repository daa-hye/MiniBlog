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

    func checkEmailValidation(_ email: String) -> Observable<String> {
        let data = Email(email: email)
        return Observable.create { [weak self] observer in
            let request = self?.provider.request(.email(model: data)) { result in
                switch result {
                case.success(let value):

                    do {
                        if let value = try? JSONDecoder()
                            .decode(MessageResponse.self, from: value.data)
                            .message {
                            observer.onNext(value)
                            observer.onCompleted()
                        }
                    }

                case.failure(let error):
                    print(error.localizedDescription)
                    observer.onError(error)
                }
            }

            return Disposables.create {
                request?.cancel()
            }
        }
    }

    func join(email: String, password: String, nick: String) -> Observable<String> {
        let data = Join(email: email, password: password, nick: nick)
        return Observable.create { [weak self] observer in
            let request = self?.provider.request(.join(model: data)) { result in
                switch result {
                case .success(let value):
                    switch value.statusCode {
                    case 200:
                        observer.onNext("가입 완료")
                        observer.onCompleted()
                    default:
                        do {
                            if let value = try? JSONDecoder()
                                .decode(MessageResponse.self, from: value.data)
                                .message {
                                observer.onNext(value)
                                observer.onCompleted()
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
