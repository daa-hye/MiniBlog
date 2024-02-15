//
//  SearchViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 2/15/24.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: BaseViewController {

    private let viewModel = SearchViewModel()

    let disposeBag = DisposeBag()

    private let searchBar = UISearchBar()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())

    private var dataSource: UICollectionViewDiffableDataSource<Int, ReadData>?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureDataSource()
        bind()
    }

    func bind() {

        searchBar.rx.text
            .compactMap { $0 }
            .debounce(.seconds(2), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.searchWord)
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

    override func configHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
    }

    override func setLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
    }

    private func configure() {
        searchBar.searchTextField.autocapitalizationType = .none
    }

}

extension SearchViewController {

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
