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

    private let titleLable = {
        let label = UILabel()
        label.text = String(localized: "시작하려면 먼저 이메일을 입력해주세요")
        return label
    }()
    private let validationButton = UIButton()
    private let idTextField = SignTextField(placeholderText: String(localized: "dahye@example.com"))
    private let signUpButton = SignButton(title: String(localized: "가입하기"))


    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }

    override func configHierarchy() {
        view.addSubview(titleLable)
        view.addSubview(idTextField)
        view.addSubview(validationButton)
        view.addSubview(signUpButton)
    }

    override func setLayout() {
        validationButton.setTitle(String(localized: "중복 확인"), for: .normal)
        validationButton.setTitleColor(.darkGray, for: .normal)
        validationButton.backgroundColor = .white
        validationButton.layer.cornerRadius = 10

        titleLable.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        validationButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(50)
            $0.top.equalTo(titleLable.snp.bottom).offset(100)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

        idTextField.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(titleLable.snp.bottom).offset(100)
            $0.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.trailing.equalTo(validationButton.snp.leading).offset(-10)
        }

        signUpButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.top.equalTo(idTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }

    }

    func bind() {

        idTextField.rx.text
            .orEmpty
            .bind(to: viewModel.input.id)
            .disposed(by: disposeBag)
        
        validationButton.rx.tap
            .bind(to: viewModel.input.validationButtonTap)
            .disposed(by: disposeBag)

        signUpButton.rx.tap
            .bind(to: viewModel.input.signUpButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.idValidation
            .subscribe(with: self) { owner, value in
                print(value)
            }
            .disposed(by: disposeBag)

    }


}
