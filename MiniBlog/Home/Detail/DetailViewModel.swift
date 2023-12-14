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
        let commentCount: Observable<String>
    }

    init(id: String) {

        self.id = id

        input = .init(
            viewDidLoad: viewDidLoad.asObserver(), 
            likeButtonTap: likeButtonTap.asObserver()
        )

        output = .init(
            title: data.map { $0.title }.observe(on: MainScheduler.instance),
            nickname: data.map { $0.creator.nick}.observe(on: MainScheduler.instance),
            image: data.map { $0.image }.observe(on: MainScheduler.instance),
            profile: data.map { $0.creator.profile }.observe(on: MainScheduler.instance),
            liked: liked.observe(on: MainScheduler.instance).asObservable(),
            likeCount: data.map {
                if $0.likes.count > 0 {
                    "좋아요 \($0.likes.count)개"
                } else {
                    ""
                }
            }.observe(on: MainScheduler.instance),
            commentCount: data.map {
                if $0.commetns.count > 0 {
                    "댓글 \($0.commetns.count)개 더보기"
                } else {
                    "댓글이 아직 없습니다"
                }
            }
        )

        viewDidLoad
            .flatMap { _ in
                APIManager.shared.read(id: id)
            }
            .subscribe(with: self) { owner, data in
                owner.data.onNext(data)
                owner.liked.onNext(data.likes.contains(LoginInfo.id))
            }
            .disposed(by: disposeBag)

        likeButtonTap
            .flatMapLatest { _ in
                APIManager.shared.like(id: id)
                    .catchAndReturn(false)
            }
            .subscribe(with: self) { owner, value in
                owner.liked.onNext(value)
            }
            .disposed(by: disposeBag)

    }

}
