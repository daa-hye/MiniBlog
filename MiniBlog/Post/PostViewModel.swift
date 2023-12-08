//
//  PostViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/30/23.
//

import Foundation
import RxSwift

final class PostViewModel: ViewModelType {

    var disposeBag = DisposeBag()

    let input: Input
    let output: Output

    private let addButtonTap = PublishSubject<Void>()
    private let title = PublishSubject<String>()
    private let picture: BehaviorSubject<Data>
    private let width: BehaviorSubject<CGFloat>
    private let height: BehaviorSubject<CGFloat>

    private let postResult = BehaviorSubject(value: false)

    struct Input {
        let addButtonTap: AnyObserver<Void>
        let title: AnyObserver<String>
        let picture: AnyObserver<Data>
    }

    struct Output {
        let picture: Observable<Data>
        let postResult: Observable<Bool>
    }

    init(data: Data, size: CGSize) {
        self.picture = .init(value: data)
        self.width = .init(value: size.width)
        self.height = .init(value: size.height)

        input = .init(
            addButtonTap: addButtonTap.asObserver(),
            title: title.asObserver(),
            picture: picture.asObserver()
        )

        output = .init(
            picture: picture.asObservable(),
            postResult: postResult.asObservable()
        )

        addButtonTap
            .withLatestFrom(Observable.combineLatest(title, picture, width, height))
            .flatMapLatest { title, picture, width, height in
                APIManager.shared.post(Post(title: title, file: picture, width: "\(width)", height: "\(height)"))
                    .catchAndReturn(Response(message: "실패", isSuccess: false))
            }
            .subscribe(with: self) { owner, result in
                owner.postResult.onNext(result.isSuccess)
            }
            .disposed(by: disposeBag)

    }

}
