//
//  UIImage + Extension.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/4/23.
//

import UIKit

extension UIImage {

    func estimateNewSize(targetSizeMB: Int) -> CGSize {

        let imageSizeBytesWhenItHas3channels = (self.pngData()?.count ?? 0) / 4 * 3
        let imageSizeMB = Double(imageSizeBytesWhenItHas3channels) / 1024.0 / 1024.0

        let targetSizeMBDouble = Double(targetSizeMB)
        let scaleFactor = sqrt(targetSizeMBDouble / imageSizeMB)

        let newSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)

        return newSize
    }

    func resizeImage(toTargetSizeMB targetSizeMB: Int, completion: @escaping (UIImage?) -> Void) {
        guard let data = self.jpegData(compressionQuality: 1.0) else { return completion(nil) }
        guard data.count > targetSizeMB else { return completion(nil) }

        let newSize = estimateNewSize(targetSizeMB: targetSizeMB)

        self.prepareThumbnail(of: newSize) { image in
            completion(image)
        }

    }

}
