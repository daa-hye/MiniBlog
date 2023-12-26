//
//  CommentCollectionViewCell.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/16/23.
//

import UIKit

final class CommentCollectionViewCell: UICollectionViewCell {

    let profileImageView = UIImageView()
    let nicknameLabel = UILabel()
    let commentLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureHierarchy()
        setLayout()
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(commentLabel)
    }

    func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.size.equalTo(40)
        }

        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }

        commentLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel.snp.leading)
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(5)
        }
    }

    func configure() {
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.main.cgColor
        nicknameLabel.font = .boldSystemFont(ofSize: 15)
        commentLabel.numberOfLines = 0
    }


}
