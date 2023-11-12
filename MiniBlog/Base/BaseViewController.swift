//
//  BaseViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/12/23.
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .main

        configHierarchy()
        setLayout()
    }

    func configHierarchy() {}
    func setLayout() {}

}
