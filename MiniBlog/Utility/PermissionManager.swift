//
//  PermissionManager.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/28/23.
//

import UIKit
import Photos

class PermissionManager {

    static func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()

        switch photoAuthorizationStatus {
        case .authorized:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    completion(true)
                case .restricted:
                    completion(false)
                case .denied:
                    completion(false)
                case .limited:
                    completion(false)
                case .notDetermined:
                    print()
                @unknown default:
                    completion(false)
                }
            }
        default:
            completion(false)
        }
    }

    static func showRequestPhotoLibraryAlert() -> UIAlertController {

        let requestPhotoLibraryAlert = UIAlertController(title: "사진 라이브러리 접근 권한 문제", message: "사진 접근 권한이 없습니다", preferredStyle: .alert)

        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }

        let cancel = UIAlertAction(title: "취소", style: .default)
        requestPhotoLibraryAlert.addAction(cancel)
        requestPhotoLibraryAlert.addAction(goSetting)

        return requestPhotoLibraryAlert

    }

}
