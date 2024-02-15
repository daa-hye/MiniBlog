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

    struct Input {
        let searchWord: AnyObserver<String>
    }

    struct Output {

    }

    init() {
        input = .init(
            searchWord: searchWord.asObserver()
        )
        output = .init()
    }

}
