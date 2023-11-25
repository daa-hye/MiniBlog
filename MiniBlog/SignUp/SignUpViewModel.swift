//
//  SignUpViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation
import RxSwift

class SignUpViewModel: ViewModelType {

    let input: Input
    let output: Output

    private let id = PublishSubject<String>()
    private let password = PublishSubject<String>()
    private let nickname = PublishSubject<String>()

    private let validationButtonTap = PublishSubject<Void>()
    private let signUpButtonTap = PublishSubject<Void>()

    private let mailFormatValidation = BehaviorSubject(value: false)
    private let idValidation = BehaviorSubject(value: false)
    private let idValidationAlertTitle = BehaviorSubject(value: "")
    private let passwordFormatValidation = BehaviorSubject(value: false)
    private let nicknameFormatValidation = BehaviorSubject(value: false)
    private let signUpValidation = BehaviorSubject(value: false)
    private let signUpResult = BehaviorSubject(value: false)
    private let signUpResultAlertTitle = BehaviorSubject(value: "")

    struct Input {
        let id: AnyObserver<String>
        let password: AnyObserver<String>
        let nickname: AnyObserver<String>
        let validationButtonTap: AnyObserver<Void>
        let signUpButtonTap: AnyObserver<Void>
    }

    struct Output {
        let mailFormatValidation: Observable<Bool>
        let idValidation: Observable<Bool>
        let idValidationAlertTitle: Observable<String>
        let signUpValidation: Observable<Bool>
        let signUpResult: Observable<Bool>
        let signUpResultAlertTitle: Observable<String>
    }

    var disposeBag = DisposeBag()

    // subject => Observable + Observer
    //observable => 관찰가능한, 관찰할 수 있는 Observe + able
    //observer => 관찰자 observe + er


    init() {
        input = .init(
            id: id.asObserver(),
            password: password.asObserver(),
            nickname: nickname.asObserver(),
            validationButtonTap: validationButtonTap.asObserver(),
            signUpButtonTap: signUpButtonTap.asObserver()
        )

        output = .init(
            mailFormatValidation: mailFormatValidation.asObservable(),
            idValidation: idValidation.asObservable(),
            idValidationAlertTitle: idValidationAlertTitle.asObservable(),
            signUpValidation: signUpValidation.asObservable(),
            signUpResult: signUpResult.asObservable(),
            signUpResultAlertTitle: signUpResultAlertTitle.asObservable()
        )

        validationButtonTap
            .withLatestFrom(id)
            .flatMap { text in
                APIManager.shared.checkEmailValidation(Email(email: text))
                    .catchAndReturn(APIManager.Response(message: "실패", isSuccess: false))
            }
            .withUnretained(self)
            .subscribe(onNext: { `self`, result in
                self.idValidation.onNext(result.isSuccess)
                self.idValidationAlertTitle.onNext(result.message)
            })
            .disposed(by: disposeBag)

        signUpButtonTap
            .withLatestFrom(Observable.combineLatest(id, password, nickname))
            .flatMapLatest { id, password, nickname in
                APIManager.shared.join(Join(email: id, password: password, nick: nickname))
                    .catchAndReturn(APIManager.Response(message: "실패", isSuccess: false))
            }
            .subscribe(with: self) { owner, result in
                owner.signUpResult.onNext(result.isSuccess)
                owner.signUpResultAlertTitle.onNext(result.message)
            }
            .disposed(by: disposeBag)

        id
            .withUnretained(self)
            .map { `self`, text -> Bool in
                self.checkEmailFormat(text)
            }
            .subscribe(mailFormatValidation)
            .disposed(by: disposeBag)

//        id
//            .subscribe(with: self) { owner, _ in
//                owner.idValidation.onNext(false)
//            }.disposed(by: disposeBag)

        password
                .map { $0.count > 5 }
                .subscribe(passwordFormatValidation)
                .disposed(by: disposeBag)
        
        nickname
            .map { $0.count > 1 }
            .subscribe(nicknameFormatValidation)
            .disposed(by: disposeBag)

        Observable.combineLatest(idValidation, passwordFormatValidation, nicknameFormatValidation)
            .map { $0 && $1 && $2 }
            .subscribe(signUpValidation)
            .disposed(by: disposeBag)

    }

}

extension SignUpViewModel {

    func checkEmailFormat(_ mail: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{2,30}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: mail)
    }

}
