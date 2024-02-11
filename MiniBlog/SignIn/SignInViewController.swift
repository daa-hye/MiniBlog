//
//  SignInViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class SignInViewController: BaseViewController {

    private let viewModel = SignInViewModel()

    private let disposeBag = DisposeBag()

    private let titleLable = UILabel()
    private let idTextField = SignTextField(placeholderText: String(localized: "이메일을 입력해주세요"))
    private let passwordTextField = SignTextField(placeholderText: String(localized: "비밀번호를 입력해주세요"))
    private let signInButton = SignButton(title: String(localized: "로그인"))
    private let signUpLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bind()
    }

    override func configHierarchy() {
        view.addSubview(titleLable)
        view.addSubview(idTextField)
        view.addSubview(passwordTextField)
        view.addSubview(signInButton)
        view.addSubview(signUpLabel)
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
            $0.top.equalTo(idTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        signInButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        signUpLabel.snp.makeConstraints {
            $0.top.equalTo(signInButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }

    private func bind() {

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

        signUpLabel.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                let vc = SignUpViewController()
                owner.present(vc, animated: true)
            }
            .disposed(by: disposeBag)

        viewModel.output.signInResult
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, value in
                if value.isSuccess {
                    let vc = TabBarController()
                    
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    guard let sceneDelegate else {
                        self.showMessage("알 수 없는 오류")
                        return
                    }

                    sceneDelegate.window?.rootViewController = vc

                } else {
                    owner.showMessage(value.message)
                }
            }
            .disposed(by: disposeBag)

    }

    private func configure() {
        titleLable.text = String(localized: "시작해볼까요?")
        titleLable.font = UIFont.boldSystemFont(ofSize: 30)
        passwordTextField.isSecureTextEntry = true

        let text = String(localized: "또는 계정 만들기")
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.foregroundColor, value: UIColor.gray, range: .init(location: 0, length: 2))
        attributedString.addAttribute(.foregroundColor, value: UIColor.main, range: .init(location: 2, length: text.count - 2))
        signUpLabel.attributedText = attributedString
        signUpLabel.textAlignment = .center

        signUpLabel.isUserInteractionEnabled = true
    }

}

