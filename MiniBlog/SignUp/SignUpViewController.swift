//
//  SignUpViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit

import RxSwift
import RxCocoa

final class SignUpViewController: BaseViewController {

    private let viewModel = SignUpViewModel()

    private let disposeBag = DisposeBag()

    private let titleLable = UILabel()
    private let validationButton = UIButton()
    private let idTextField = SignTextField(placeholderText: String(localized: "이메일"))
    private let passwordTextField = SignTextField(placeholderText: String(localized: "비밀번호"))
    private let nicknameTextField = SignTextField(placeholderText: String(localized: "닉네임"))
    private let signUpButton = SignButton(title: String(localized: "가입하기"))


    override func viewDidLoad() {
        super.viewDidLoad()

        congigure()
        bind()
    }

    func bind() {

        idTextField.rx.text
            .orEmpty
            .bind(to: viewModel.input.id)
            .disposed(by: disposeBag)

        passwordTextField.rx.text
            .orEmpty
            .bind(to: viewModel.input.password)
            .disposed(by: disposeBag)

        nicknameTextField.rx.text
            .orEmpty
            .bind(to: viewModel.input.nickname)
            .disposed(by: disposeBag)

        validationButton.rx.tap
            .bind(to: viewModel.input.validationButtonTap)
            .disposed(by: disposeBag)

        signUpButton.rx.tap
            .bind(to: viewModel.input.signUpButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.mailFormatValidation
            .bind(with: self) { owner, value in

                owner.validationButton.isEnabled = value

                let color = value ? UIColor.black : UIColor.lightGray

                owner.validationButton.setTitleColor(color, for: .normal)
                owner.validationButton.layer.borderColor = color.cgColor
            }
            .disposed(by: disposeBag)

        viewModel.output.idValidationAlertTitle
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)

//        viewModel.output.signUpValidation
//            .bind(with: self, onNext: { owner, value in
//                owner.signUpButton.rx.isEnabled.onNext(value)
//
//                let color = value ? UIColor.main : UIColor.lightGray
//                owner.signUpButton.rx.backgroundColor.onNext(color)
//            })
//            .disposed(by: disposeBag)

        viewModel.output.signUpResultAlertTitle
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)

        viewModel.output.signUpResult
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)

    }


    override func configHierarchy() {
        view.addSubview(titleLable)
        view.addSubview(idTextField)
        view.addSubview(validationButton)
        view.addSubview(passwordTextField)
        view.addSubview(nicknameTextField)
        view.addSubview(signUpButton)
    }

    override func setLayout() {

        titleLable.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        validationButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(50)
            $0.top.equalTo(titleLable.snp.bottom).offset(60)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        idTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(titleLable.snp.bottom).offset(60)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.trailing.equalTo(validationButton.snp.leading).offset(-10)
        }

        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(idTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        nicknameTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        signUpButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }

    }

    private func congigure() {
        validationButton.setTitle(String(localized: "중복 확인"), for: .normal)
        validationButton.setTitleColor(.black, for: .normal)
        validationButton.backgroundColor = .white
        validationButton.layer.cornerRadius = 10
        validationButton.layer.borderColor = UIColor.black.cgColor
        validationButton.layer.borderWidth = 1

        titleLable.text = String(localized: "계정을 생성하세요")
        titleLable.font = UIFont.boldSystemFont(ofSize: 30)
    }

}
