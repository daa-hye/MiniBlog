//
//  HomeViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/7/23.
//

import Foundation
import RxSwift

final class HomeViewModel: ViewModelType {

    var disposeBag = DisposeBag()

    let input: Input
    let output: Output

    private let viewWillAppear = PublishSubject<Void>()
    private let data: BehaviorSubject<[ReadData]> = BehaviorSubject(value: [])
    private let cursor = BehaviorSubject(value: "")

    struct Input {
        let viewWillAppear: AnyObserver<Void>
    }

    struct Output {
        let data: Observable<[ReadData]>
    }

    init() {
        input = .init(
            viewWillAppear: viewWillAppear.asObserver()
        )

        output = .init(
            data: data.observe(on: MainScheduler.instance)
        )

        viewWillAppear
            .flatMap { _ in
                APIManager.shared.read(cursor: "")
                .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
            }
            .subscribe(with: self) { owner, response in
                owner.data.onNext(response.data)
                owner.cursor.onNext(response.nextCursor)
            }
            .disposed(by: disposeBag)

    }


}
