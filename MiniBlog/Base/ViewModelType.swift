//
//  ViewModelType.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/13/23.
//

import Foundation
import RxSwift

protocol ViewModelType {

    associatedtype AA
    associatedtype BB

    var disposeBag: DisposeBag { get set }

    var input: AA { get }
    var output: BB { get }

}
