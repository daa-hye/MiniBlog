//
//  DetailViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/11/23.
//

import Foundation
import RxSwift

class DetailViewModel: ViewModelType {

    let input: Input
    let output: Output

    var disposeBag = DisposeBag()

    private let data: BehaviorSubject<ReadData>

    private let title: BehaviorSubject<String>
    private let photo: BehaviorSubject<URL>

    struct Input {

    }

    struct Output {
        let title: Observable<String>
        let photo: Observable<URL>
    }

    init(data: ReadData) {
        self.data = .init(value: data)
        self.title = .init(value: data.title)
        self.photo = .init(value: data.image)

        input = .init()

        output = .init(
            title: title,
            photo: photo
        )

    }


}
