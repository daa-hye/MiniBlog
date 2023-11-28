//
//  UIViewController + Extension.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/26/23.
//

import UIKit

extension UIViewController {

    func showMessage(_ message: String) {
        
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)

        let confirm = UIAlertAction(title: "확인", style: .default)
        alert.addAction(confirm)

        present(alert, animated: true)

    }

}
