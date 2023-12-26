//
//  CommentViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/16/23.
//

import Foundation
import RxSwift

final class CommentViewModel: ViewModelType {
    
    var disposeBag = DisposeBag()

    let input: Input
    let output: Output

    private let comments = PublishSubject<[Comments]>()
    private let id: String

    private let viewDidLoad = PublishSubject<Void>()
    private let content = PublishSubject<String>()
    private let writeComment = PublishSubject<Void>()

    struct Input {
        let viewDidLoad: AnyObserver<Void>
        let content: AnyObserver<String>
        let writeComment: AnyObserver<Void>
    }

    struct Output {
        let comments: Observable<[Comments]>
    }

    init(id: String) {
        self.id = id

        self.input = .init(
            viewDidLoad: viewDidLoad.asObserver(),
            content: content.asObserver(),
            writeComment: writeComment.asObserver()
        )
        self.output = .init(
            comments: comments.observe(on: MainScheduler.instance).asObservable()
        )

        viewDidLoad
            .flatMap { _ in
                APIManager.shared.getComments(id)
            }
            .subscribe(with: self) { owner, value in
                owner.comments.onNext(value)
            }
            .disposed(by: disposeBag)

        writeComment
            .withLatestFrom(content)
            .flatMap { content in
                APIManager.shared.comment(id: id, model: Comment(content: content))
            }
            .filter { $0.isSuccess }
            .flatMap { _ in
                APIManager.shared.getComments(id)
            }
            .subscribe(with: self) { owner, value in
                owner.comments.onNext(value)
            }
            .disposed(by: disposeBag)
    }

}
