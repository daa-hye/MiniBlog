//
//  ReferencedList.swift
//  MiniBlog
//
//  Created by 박다혜 on 1/1/24.
//

import Foundation

final class ReferencedList<T> {
    var list: [T]

    init(list: [T]) {
        self.list = list
    }

    subscript(index: Int) -> T? {
            get {
                guard index >= 0, index < list.count else {
                    return nil
                }
                return list[index]
            }
            set {
                guard let newValue = newValue, index >= 0, index < list.count else {
                    return
                }
                list[index] = newValue
            }
        }

        func append(_ element: T) {
            list.append(element)
        }

    func append(contentsOf otherList: [T]) {
            list.append(contentsOf: otherList)
        }

        func count() -> Int {
            return list.count
        }
}
