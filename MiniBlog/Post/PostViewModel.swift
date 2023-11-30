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

    struct Input {

    }

    struct Output {

    }

    init(input: Input, output: Output) {
        self.input = input
        self.output = output
    }

}
