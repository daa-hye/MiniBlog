//
//  ProfileViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/18/23.
//

import Foundation
import RxSwift

final class ProfileViewModel: ViewModelType {

    var disposeBag = DisposeBag()

    let input: Input
    let output: Output

    private let viewWillAppear = PublishSubject<Void>()
    private let profile = PublishSubject<Profile>()
    private let posts: BehaviorSubject<[ReadData]> = BehaviorSubject(value: [])
    private let cursor = BehaviorSubject(value: "")

    struct Input {
        let viewWillAppear: AnyObserver<Void>
    }

    struct Output {
        let profileImage: Observable<URL>
        let email: Observable<String>
        let posts: Observable<[ReadData]>
    }

    init() {
        input = .init(
            viewWillAppear: viewWillAppear.asObserver()
        )
        
        output = .init(
            profileImage: profile.map { $0.profile! }.observe(on: MainScheduler.instance),
            email: profile.map { $0.email }.observe(on: MainScheduler.instance),
            posts: posts.observe(on: MainScheduler.instance)
        )

        viewWillAppear
            .withUnretained(self)
            .flatMapLatest { _ in
                APIManager.shared.profile()
                    .flatMap { profile in
                        APIManager.shared.readUser(id: profile.id, cursor: "")
                            .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
                            .map {(profile, $0)}
                    }
            }
            .subscribe { profile, data in
                self.profile.onNext(profile)
                self.posts.onNext(data.data)
                self.cursor.onNext(data.nextCursor)
            }
            .disposed(by: disposeBag)
    }

}
