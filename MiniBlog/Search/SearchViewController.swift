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

    let disposebag = DisposeBag()

    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
    }

    func bind() {
        searchBar.rx.text
            .compactMap { $0 }
            .debounce(.seconds(2), scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.searchWord)
            .disposed(by: disposebag)
    }

    override func configHierarchy() {
        view.addSubview(searchBar)
    }

    override func setLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }

    private func configure() {
        searchBar.autocapitalizationType = .none
    }

}
