//
//  DetailViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/11/23.
//

import Foundation
import RxSwift

final class DetailViewModel: ViewModelType {

    let input: Input
    let output: Output

    var disposeBag = DisposeBag()

    private let viewDidLoad = PublishSubject<Void>()
    private let viewWillAppear = PublishSubject<Void>()
    private let likeButtonDidTap = PublishSubject<Void>()

    private let data = PublishSubject<ReadDetail>()
    let id: String

    private let liked = PublishSubject<Bool>()
    private let likeCount = PublishSubject<Int>()
    private let commentCount = PublishSubject<Int>()

    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let viewWillAppear: AnyObserver<Void>
        let likeButtonDidTap: AnyObserver<Void>
    }
    
    struct Output {
        let title: Observable<String>
        let nickname: Observable<String>
        let image: Observable<URL>
        let profile: Observable<URL?>
        let liked: Observable<Bool>
        let likeCount: Observable<String>
        let commentCount: Observable<String>
        let hashtags: Observable<[String]>
    }

    init(id: String) {

        self.id = id

        input = .init(
            viewDidLoad: viewDidLoad.asObserver(),
            viewWillAppear: viewWillAppear.asObserver(),
            likeButtonDidTap: likeButtonDidTap.asObserver()
        )

        output = .init(
            title: data.map { $0.title }.observe(on: MainScheduler.instance),
            nickname: data.map { $0.creator.nick}.observe(on: MainScheduler.instance),
            image: data.map { $0.image }.observe(on: MainScheduler.instance),
            profile: data.map { $0.creator.profile }.observe(on: MainScheduler.instance),
            liked: liked.observe(on: MainScheduler.instance),
            likeCount: likeCount.map {
                if $0 > 0 {
                    "좋아요 \($0)개"
                } else {
                    ""
                }
            }.observe(on: MainScheduler.instance),
            commentCount: commentCount.map {
                if $0 > 0 {
                    "댓글 \($0)개 모두 보기"
                } else {
                    "댓글이 아직 없습니다"
                }
            }.observe(on: MainScheduler.instance),
            hashtags: data.map { $0.hashTags }.observe(on: MainScheduler.instance)
        )

        viewDidLoad
            .flatMap { _ in
                APIManager.shared.read(id: id)
            }
            .subscribe(with: self) { owner, data in
                owner.data.onNext(data)
                owner.liked.onNext(data.likes.contains(LoginInfo.id))
                owner.likeCount.onNext(data.likes.count)
                owner.commentCount.onNext(data.comments.count)
                print(data.hashTags)
            }
            .disposed(by: disposeBag)

        viewWillAppear
            .flatMap { _ in
                APIManager.shared.getComments(id)
            }
            .map { $0.count }
            .bind(to: commentCount)
            .disposed(by: disposeBag)

        likeButtonDidTap
            .flatMapLatest { _ in
                APIManager.shared.like(id: id)
                .catchAndReturn(false)
                .flatMap { liked in
                    APIManager.shared.getLikes(id)
                        .catchAndReturn(0)
                        .map { (liked, $0) }
                }
            }
            .subscribe(onNext: { [weak self] liked, likeCount in
                self?.liked.onNext(liked)
                self?.likeCount.onNext(likeCount)
            })
            .disposed(by: disposeBag)
    }

}
