//
//  SearchViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 2/15/24.
//

import Foundation
import RxSwift

class SearchViewModel: ViewModelType {

    let input: Input
    let output: Output

    var disposeBag = DisposeBag()

    private let searchWord = PublishSubject<String>()
    private let data: BehaviorSubject<ReferencedList<ReadData>> = BehaviorSubject(value: .init(list: []))

    struct Input {
        let searchWord: AnyObserver<String>
    }

    struct Output {
        let data: Observable<[ReadData]>
    }

    init() {

        input = .init(
            searchWord: searchWord.asObserver()
        )
        output = .init(
            data: data.map { $0.list }.observe(on: MainScheduler.instance)
        )

        searchWord
            .map { $0.lowercased() }
            .flatMapLatest { query in
                APIManager.shared.search(query: query)
                    .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
            }
            .subscribe(with: self) { owner, response in
                owner.data.onNext(.init(list: response.data))
            }
            .disposed(by: disposeBag)

    }

}
