//
//  TabBarController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/27/23.
//

import UIKit
import Photos
import PhotosUI

final class TabBarController: UITabBarController {

    override func viewDidLoad() {

        super.viewDidLoad()

        self.delegate = self

        tabBar.tintColor = .black

        let homeView = {
            let view = HomeViewController()
            view.tabBarItem.image = UIImage(systemName: "house.fill")
            return view
        }()

        let postView = {
            let view = PostViewController()
            view.tabBarItem.image = UIImage(systemName: "plus.circle.fill")
            return view
        }()

        setViewControllers([homeView, postView], animated: true)


    }

}

extension TabBarController {

    private func presentPickerView() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1

        if #available(iOS 16.0, *) {
            configuration.filter = .any(of: [.images, .depthEffectPhotos, .livePhotos])
        } else {
            configuration.filter = .images
        }

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    private func checkPermission() {
        PermissionManager.checkPhotoLibraryPermission { value in
            if value {
                self.presentPickerView()
            } else {

            }
        }
    }

}

extension TabBarController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        if let result = results.first {
            let view = PostViewController()
            view.modalPresentationStyle = .fullScreen
            present(view, animated: true)
        }
    }
}

extension TabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PostViewController {
            checkPermission()
            return false
        }
        return true
    }

}
