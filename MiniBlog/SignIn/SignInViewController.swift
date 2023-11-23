//
//  SignInViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit
import RxSwift
import RxCocoa

final class SignInViewController: BaseViewController {

    private let viewModel = SignInViewModel()

    private let disposeBag = DisposeBag()

    private let titleLable = {
        let label = UILabel()
        label.text = String(localized: "시작해볼까요?")
        return label
    }()

    private let idTextField = {
        let view = SignTextField(placeholderText: String(localized: "이메일을 입력해주세요"))
        return view
    }()

    private let passwordTextField = {
        let view = SignTextField(placeholderText: String(localized: "비밀번호를 입력해주세요"))
        return view
    }()

    private let signInButton = {
        let button = SignButton(title: String(localized: "로그인"))
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    override func configHierarchy() {
        view.addSubview(titleLable)
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
    }

    override func setLayout() {

        titleLable.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        idTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(titleLable.snp.bottom).offset(100)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        passwordTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(idTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        signInButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
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

        signInButton.rx.tap
            .bind(to: viewModel.input.signInButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.signInResult
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)

    }

}

