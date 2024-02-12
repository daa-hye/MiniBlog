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
    private let prefetchItems = PublishSubject<[IndexPath]>()
    private let data: BehaviorSubject<ReferencedList<ReadData>> = BehaviorSubject(value: .init(list: []))
    private let cursor = BehaviorSubject(value: "")

    struct Input {
        let viewWillAppear: AnyObserver<Void>
        let prefetchItems: AnyObserver<[IndexPath]>
    }

    struct Output {
        let data: Observable<[ReadData]>
    }

    init() {
        input = .init(
            viewWillAppear: viewWillAppear.asObserver(), 
            prefetchItems: prefetchItems.asObserver()
        )

        output = .init(
            data: data.map { $0.list }.observe(on: MainScheduler.instance)
        )

        viewWillAppear
            .flatMap { _ in
                APIManager.shared.read(cursor: "")
                .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
            }
            .subscribe(with: self) { owner, response in
                owner.data.onNext(.init(list: response.data))
                owner.cursor.onNext(response.nextCursor)
            }
            .disposed(by: disposeBag)

        prefetchItems
            .compactMap { $0[$0.count-1] }
            .withLatestFrom(data) { ($0, $1) }
            .map { (indexPath, data) -> (Bool, ReferencedList<ReadData>) in
                let standard = Int(Double(data.count()) * 0.6)
                return (indexPath.item > standard , data)
            }
            .filter { $0.0 }
            .withLatestFrom(cursor) { ($0.1, $1) }
            .filter { $0.1 != "0"}
            .flatMapLatest { (data, cursor) -> Single<(ReferencedList<ReadData>, ReadResponse)> in
                APIManager.shared.read(cursor: cursor)
                    .catchAndReturn(ReadResponse(data: [], nextCursor: "0"))
                    .map { ( data, $0) }
            }
            .subscribe { [weak self] (data, response) in
                data.append(contentsOf: response.data)

                self?.data.onNext(data)
                self?.cursor.onNext(response.nextCursor)
            }
            .disposed(by: disposeBag)

    }


}




