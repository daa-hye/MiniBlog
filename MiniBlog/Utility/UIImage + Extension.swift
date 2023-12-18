//
//  UIImage + Extension.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/4/23.
//

import UIKit

extension UIImage {

    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func compressImage() -> Data? {
        var newSize = CGSize(width: size.width, height: size.height)
        var newData = self.jpegData(compressionQuality: 1.0) ?? Data()
        let targetSizeInBytes = 10 * 1024 * 1024

        if let data = self.jpegData(compressionQuality: 1.0),
              data.count <= targetSizeInBytes {
            return data
        }

        while let data = self.jpegData(compressionQuality: 1.0), data.count > targetSizeInBytes {
            newSize = CGSize(width: newSize.width * 0.9, height: newSize.height * 0.9)
            UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
            self.draw(in: CGRect(origin: .zero, size: newSize))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            if let compressedData = newImage?.jpegData(compressionQuality: 1.0) {
                newData = compressedData
                if newData.count <= targetSizeInBytes {
                    return newData
                }
            }
        }

        return nil
    }

}
