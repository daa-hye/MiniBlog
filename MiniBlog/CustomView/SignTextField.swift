//
//  SignTextField.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit

class SignTextField: UITextField {

    init(placeholderText: String) {
        super.init(frame: .zero)

        textColor = .darkGray
        backgroundColor = .white
        placeholder = placeholderText
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 10
        layer.borderWidth = 3
        layer.borderColor = UIColor.second.cgColor
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
