//
//  SignInViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/23/23.
//

import Foundation
import RxSwift

class SignInViewModel: ViewModelType {
    
    let input: Input
    let output: Output

    private let id = PublishSubject<String>()
    private let password = PublishSubject<String>()
    
    private let signInButtonTap = PublishSubject<Void>()
    private let signInValidation = BehaviorSubject(value: false)
    private let signInResult = PublishSubject<Response>()


    struct Input {
        let id: AnyObserver<String>
        let password: AnyObserver<String>
        let signInButtonTap: AnyObserver<Void>
    }

    struct Output {
        let signInValidation: Observable<Bool>
        let signInResult: Observable<Response>
    }

    var disposeBag = DisposeBag()

    init() {

        input = .init(
            id: id.asObserver(),
            password: password.asObserver(),
            signInButtonTap: signInButtonTap.asObserver()
        )

        output = .init(
            signInValidation: signInValidation.asObservable(),
            signInResult: signInResult.asObservable()
        )

        signInButtonTap
            .withLatestFrom(Observable.combineLatest(id, password))
            .flatMapLatest { id, password in
                APIManager.shared.login(Login(email: id, password: password))
                    .catchAndReturn(Response(message: "실패", isSuccess: false))
            }
            .subscribe(with: self) { owner, result in
                owner.signInResult.onNext(result)
            }
            .disposed(by: disposeBag)

    }

}
