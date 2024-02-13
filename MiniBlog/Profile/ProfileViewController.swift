//
//  ProfileViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/18/23.
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: BaseViewController {

    private let viewModel = ProfileViewModel()
    private let disposeBag = DisposeBag()

    private var dataSource: UICollectionViewDiffableDataSource<Int, ReadData>?

    private let profileImageView = UIImageView()
    private let emailLabel = UILabel()
    private let nicknameLabel = UILabel()
    private let editButton = UIButton()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        bind()
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        viewModel.input.viewWillAppear.onNext(())
    }

    func bind() {

        viewModel.output.profileImage
            .subscribe(with: self) { owner, url in
                owner.profileImageView.kf.setImage(with: url)
            }
            .disposed(by: disposeBag)

        viewModel.output.nickname
            .bind(to: nicknameLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.email
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.posts
            .subscribe(with: self) { owner, data in
                let ratios = data.map{ Ratio(ratio: CGFloat(($0.width! as NSString).floatValue)/CGFloat(($0.height! as NSString).floatValue)) }

                let layout = HomeViewLayout(columnsCount: 3, itemRatios: ratios, spacing: 5, contentWidth: owner.view.frame.width)

                owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)

                var snapshot = NSDiffableDataSourceSnapshot<Int,ReadData>()
                snapshot.appendSections([0])
                snapshot.appendItems(data, toSection: 0)
                owner.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .disposed(by: disposeBag)
    }

    override func configHierarchy() {
        view.addSubview(profileImageView)
        view.addSubview(emailLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(editButton)
        view.addSubview(collectionView)
    }

    override func setLayout() {
        
        profileImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.size.equalTo(70)
        }

        nicknameLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(10)
        }

        emailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(7)
        }

        editButton.snp.makeConstraints {
            $0.top.equalTo(emailLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(30)
            $0.width.equalTo(100)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(editButton.snp.bottom).offset(30)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }

    private func configure() {
        profileImageView.layer.cornerRadius = 35
        nicknameLabel.font = .boldSystemFont(ofSize: 20)
        emailLabel.textColor = .gray
        editButton.backgroundColor = .main
        editButton.layer.cornerRadius = 10
        editButton.setTitleColor(.white, for: .normal)
        editButton.setTitle(String(localized: "프로필 편집"), for: .normal)
    }

}

extension ProfileViewController {

    func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<HomeCollectionViewCell, ReadData> { cell, indexPath, itemIdentifier in
                cell.imageView.kf.setImage(with: itemIdentifier.image, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
            }

        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
                let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
                return cell
            })
    }

}
