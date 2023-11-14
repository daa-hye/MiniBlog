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

    private let text = PublishSubject<String>()
    private let validation = PublishSubject<Void>()
    private let signUp = PublishSubject<Void>()

    private let mailFormatValidation = BehaviorSubject(value: false)
    private let idValidation = BehaviorSubject(value: false)
    private let signUpValidation = BehaviorSubject(value: false)

    struct Input {
        let id: AnyObserver<String>
        let validationButtonTap: AnyObserver<Void>
        let signUpButtonTap: AnyObserver<Void>
    }

    struct Output {
        let mailFormatValidation: Observable<Bool>
        let idValidation: Observable<Bool>
        let signUpResult: Observable<Bool>
    }

    var disposeBag = DisposeBag()

    // subject => Observable + Observer
    //observable => 관찰가능한, 관찰할 수 있는 Observe + able
    //observer => 관찰자 observe + er


    init() {
        input = .init(
            id: text.asObserver(),
            validationButtonTap: validation.asObserver(),
            signUpButtonTap: signUp.asObserver()
        )

        output = .init(
            mailFormatValidation: mailFormatValidation.asObservable(),
            idValidation: idValidation.asObservable(),
            signUpResult: signUpValidation.asObservable()
        )


        validation
            .withLatestFrom(text)
            .flatMap { text in
                APIManager.shared.checkEmailValidation(text)
                    .catchAndReturn(false)
            }
            .withUnretained(self)
            .subscribe(onNext: { `self`, result in
                self.idValidation.onNext(result)
            })
            .disposed(by: disposeBag)

        text
            .withUnretained(self)
            .map { `self`, text -> Bool in
                self.checkEmailFormat(text)
            }
            .subscribe(mailFormatValidation)
            .disposed(by: disposeBag)

    }

}

extension SignUpViewModel {

    func checkEmailFormat(_ mail: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{2,30}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: mail)
    }

}
