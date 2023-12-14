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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let viewWillAppearObservable = Observable<Void>.create { observer in
            observer.onNext(())
            return Disposables.create()
        }

        viewWillAppearObservable
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
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

        collectionView.rx.itemSelected
            .subscribe(with: self) { owner, indexPath in
                if let data = owner.dataSource?.itemIdentifier(for: indexPath) {
                    let vc = DetailViewController(viewModel: .init(id: data.id))
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    nav.modalTransitionStyle = .flipHorizontal
                    owner.present(nav, animated: true)
                }
            }
            .disposed(by: disposeBag)

        viewModel.output.data
            .subscribe(with: self) { owner, data in

                let ratios = data.map{ Ratio(ratio: CGFloat(($0.width! as NSString).floatValue)/CGFloat(($0.height! as NSString).floatValue)) }

                let layout = HomeViewLayout(columnsCount: 2, itemRatios: ratios, spacing: 10, contentWidth: owner.view.frame.width)

                owner.collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: layout.section)

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
