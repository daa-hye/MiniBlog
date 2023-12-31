//
//  ViewModelType.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation
import RxSwift

protocol ViewModelType {

    associatedtype Input
    associatedtype Output

    var disposeBag: DisposeBag { get set }

    var input: Input { get }
    var output: Output { get }

}
