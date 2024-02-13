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

    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    private var dataSource: UICollectionViewDiffableDataSource<Int, ReadData>?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.input.viewWillAppear.onNext(())
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
            .bind(with: self) { owner, indexPath in
                if let data = owner.dataSource?.itemIdentifier(for: indexPath) {
                    let vc = DetailViewController(viewModel: .init(id: data.id))
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .fullScreen
                    nav.modalTransitionStyle = .flipHorizontal
                    owner.present(nav, animated: true)
                }
            }
            .disposed(by: disposeBag)

        collectionView.rx.prefetchItems
            .throttle(.seconds(1), scheduler: MainScheduler.asyncInstance)
            .bind(to: viewModel.input.prefetchItems)
            .disposed(by: disposeBag)

        viewModel.output.data
            .bind(with: self) { owner, data in

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
}
