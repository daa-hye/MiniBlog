//
//  ProfileEditViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 2/16/24.
//

import Foundation
import RxSwift
import RxRelay

class ProfileEditViewModel: ViewModelType {

    let input: Input
    let output: Output

    var disposeBag = DisposeBag()

    private let nickname: String
    private let profile: URL
    private let editButtonDidTap = PublishSubject<Void>()
    private let newProfile = BehaviorSubject<Data?>(value: nil)
    private let newNickname: BehaviorSubject<String>

    struct Input {
        let editButtonDidTap: AnyObserver<Void>
        let newProfile: AnyObserver<Data?>
        let newNickname: AnyObserver<String>
    }

    struct Output {
        let nickname: Observable<String>
        let profile: Observable<URL>
    }

    init(nickname: String, profile: URL) {

        self.nickname = nickname
        self.profile = profile

        newNickname = .init(value: nickname)

        input = .init(
            editButtonDidTap: editButtonDidTap.asObserver(),
            newProfile: newProfile.asObserver(),
            newNickname: newNickname.asObserver()
        )
        
        output = .init(
            nickname: BehaviorSubject(value: nickname).observe(on: MainScheduler.instance),
            profile: BehaviorSubject(value: profile).observe(on: MainScheduler.instance)
        )

        editButtonDidTap
            .withLatestFrom(Observable.combineLatest(newNickname, newProfile))
            .flatMapLatest { (newNickname, newProfile) in
                APIManager.shared.editProfile(nick: newNickname, image: newProfile)
            }
            .subscribe(with: self) { owner, _ in
                //
            }
            .disposed(by: disposeBag)
    }

}
