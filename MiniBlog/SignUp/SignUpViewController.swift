//
//  SignUpViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit

final class SignUpViewController: BaseViewController {

    private let titleLable = {
        let label = UILabel()
        label.text = String(localized: "시작하려면 먼저 이메일을 입력해주세요")
        return label
    }()
    private let validationButton = UIButton()
    private let idTextField = SignTextField(placeholderText: String(localized: "dahye@example.com"))

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configHierarchy() {
        view.addSubview(titleLable)
        view.addSubview(idTextField)
        view.addSubview(validationButton)
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

    }


}
