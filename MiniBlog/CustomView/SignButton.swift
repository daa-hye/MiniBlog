//
//  SignButton.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit

class SignButton: UIButton {

    init(title: String) {
        super.init(frame: .zero)

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        backgroundColor = .main
        layer.cornerRadius = 20
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
