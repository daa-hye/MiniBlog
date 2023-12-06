//
//  HomeViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/26/23.
//

import UIKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController {

    let disposeBag = DisposeBag()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureTagLayout())

    //var dataSource: UICollectionViewDiffableDataSource<Int, Data>

    let image = {
        let view = UIImageView()
        view.backgroundColor = .black
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        APIManager.shared.read()
            .subscribe(with: self) { owner, response in
                for i in response.data {
                    print(i.image)
                }
                if let url = URL(string: Lslp.url + response.data[0].image[0]) {
                    DispatchQueue.main.async {
                        owner.image.kf.setImage(with: url, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
                    }
                }
            }
            .disposed(by: disposeBag)
    }

    override func configHierarchy() {
        view.addSubview(image)
    }

    override func setLayout() {
        image.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
        }
    }

}

extension HomeViewController {

    func configureTagLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(150))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(150))

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)

        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        section.interGroupSpacing = 10

        let configure = UICollectionViewCompositionalLayoutConfiguration()
        configure.scrollDirection = .vertical

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = configure

        return layout
    }

}
