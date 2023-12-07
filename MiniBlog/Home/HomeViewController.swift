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

    let viewModel = HomeViewModel()

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureTagLayout())

    var dataSource: UICollectionViewDiffableDataSource<Int, ReadData>?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        bind()
    }

    override func configHierarchy() {
        view.addSubview(collectionView)
    }

    override func setLayout() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    func bind() {
        let viewDidLoadObservable = Observable<Void>.just(())

        viewDidLoadObservable
            .bind(to: viewModel.input.viewDidLoad)
            .disposed(by: disposeBag)

        viewModel.output.data
            .subscribe(with: self) { owner, data in
                var snapshot = NSDiffableDataSourceSnapshot<Int,ReadData>()
                snapshot.appendSections([0])
                snapshot.appendItems(data, toSection: 0)
                owner.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .disposed(by: disposeBag)
    }

}

extension HomeViewController {

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
