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
            data: data.asObservable()
        )

        // TODO: 수정
        viewWillAppear
            .bind(with: self) { owner, _ in
                DispatchQueue.main.async {
                    APIManager.shared.read()
                        .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
                        .map { $0.data }
                        .subscribe(with: self) { owner, data in
                            owner.data.onNext(data)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)

    }


}
