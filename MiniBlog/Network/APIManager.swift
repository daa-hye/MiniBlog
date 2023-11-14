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

    let provider = MoyaProvider<lslpAPI>()

    func makeObservable() -> Observable<Int> {
        return Observable.just(1)
    }

    func checkEmailValidation(_ email: String) -> Observable<Bool> {
        let data = Email(email: email)
        return Observable.create { [weak self] observer in
            let request = self?.provider.request(.email(model: data)) { result in
                switch result {
                case.success(let value):
                    switch value.statusCode {
                    case 200:
                        observer.onNext(true)
                        observer.onCompleted()
                    case 400:
                        print("필수값 안채움")
                        observer.onNext(false)
                        observer.onCompleted()
                    case 409:
                        print("이미 있음")
                        observer.onNext(false)
                        observer.onCompleted()
                    case 500:
                        print("서버에러")
                        observer.onNext(false)
                        observer.onCompleted()
                    default:
                        observer.onNext(false)
                        observer.onCompleted()
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
}
