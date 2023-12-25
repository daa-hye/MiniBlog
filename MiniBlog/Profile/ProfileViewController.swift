//
//  ProfileViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/18/23.
//

import UIKit

final class ProfileViewController: BaseViewController {

    private let profileImageView = UIImageView()
    private let emailLabel = UILabel()
    private let profileButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

    override func viewWillAppear(_ animated: Bool) {
        <#code#>
    }

    override func configHierarchy() {
        view.addSubview(profileImageView)
        view.addSubview(emailLabel)
        view.addSubview(profileButton)
        view.addSubview(collectionView)
    }

    override func setLayout() {
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.size.equalTo(70)
        }

        emailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
        }

        profileButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
            $0.width.equalTo(100)
        }

        collectionView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
    }

    private func configure() {
        profileImageView.layer.cornerRadius = 35
        emailLabel.font = .boldSystemFont(ofSize: 20)
        profileButton.backgroundColor = .main
        profileButton.setTitleColor(.white, for: .normal)
    }

}
