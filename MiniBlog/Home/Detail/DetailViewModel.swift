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

    private let viewDidLoad = PublishSubject<Void>()

    private let data = PublishSubject<ReadDetail>()

    struct Input {
        let viewDidLoad: AnyObserver<Void>
    }

    struct Output {
        let data: Observable<ReadDetail>
    }

    init(id: String) {

        input = .init(
            viewDidLoad: viewDidLoad.asObserver()
        )

        output = .init(
            data: data.asObservable()
        )

        viewDidLoad
            .bind(with: self) { owner, _ in
                DispatchQueue.main.async {
                    APIManager.shared.read(id: id)
                        .catchAndReturn(ReadDetail())
                        .subscribe(with: self) { owner, data in
                            owner.data.onNext(data)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: disposeBag)
    }

}
