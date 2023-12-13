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
    private let likeButtonTap = PublishSubject<Void>()

    private let data = PublishSubject<ReadDetail>()
    private let id: String

    private let liked = PublishSubject<Bool>()

    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let likeButtonTap: AnyObserver<Void>
    }

    struct Output {
        let title: Observable<String>
        let nickname: Observable<String>
        let image: Observable<URL>
        let profile: Observable<URL?>
        let liked: Observable<Bool>
        let likeCount: Observable<String>
    }

    init(id: String) {

        self.id = id

        input = .init(
            viewDidLoad: viewDidLoad.asObserver(), 
            likeButtonTap: likeButtonTap.asObserver()
        )

        output = .init(
            title: data.map { $0.title },
            nickname: data.map { $0.creator.nick},
            image: data.map { $0.image },
            profile: data.map { $0.creator.profile },
            liked: liked.asObservable(),
            likeCount: data.map {
                if $0.likes.count > 0 {
                    "좋아요 \($0.likes.count)개"
                } else {
                    ""
                }
            }
        )


        // TODO: 수정
        viewDidLoad
            .bind(with: self) { owner, _ in
                APIManager.shared.read(id: id)
                //error
                    .subscribe(with: self) { owner, data in
                        owner.data.onNext(data)
                        owner.liked.onNext(data.likes.contains(LoginInfo.id))
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)

        likeButtonTap
            .flatMap { _ in
                APIManager.shared.like(id: id)
                    .catchAndReturn(false)
            }
            .subscribe(with: self) { owner, value in
                owner.liked.onNext(value)
            }
            .disposed(by: disposeBag)

    }

}
