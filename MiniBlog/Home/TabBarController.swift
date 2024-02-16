//
//  TabBarController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/27/23.
//

import UIKit
import PhotosUI
import Kingfisher

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
            let view = PostViewController(viewModel: PostViewModel(data: Data(), size: CGSize()))
            view.tabBarItem.image = UIImage(systemName: "plus.circle.fill")
            return view
        }()

        let searchView = {
            let view = SearchViewController()
            view.tabBarItem.image = UIImage(systemName: "magnifyingglass")
            return view
        }()

        let likeView = {
            let view = LikeViewController()
            view.tabBarItem.image = UIImage(systemName: "heart")
            return view
        }()

        let profileView = {
            let view = ProfileViewController()
            getProfile { image in
                view.tabBarItem.image = image.withRenderingMode(.alwaysOriginal)
            }
            return view
        }()

        setViewControllers([homeView, searchView, postView, likeView, profileView], animated: true)

    }

}

extension TabBarController {

    private func getProfile(completion: @escaping (UIImage) -> Void ) {
        let targetSize = CGSize(width: 24.0, height: 24.0)
        let resize = ResizingImageProcessor(referenceSize: targetSize, mode: .aspectFill)
        let round = RoundCornerImageProcessor(cornerRadius: 12.0)
        let crop = CroppingImageProcessor(size: targetSize)
        let border = BorderImageProcessor(border: Border(color: .main, lineWidth: 1, radius: .widthFraction(targetSize.height / 2), roundingCorners: .all))

        let processor = ((resize |> crop |> round) |> border)

        KingfisherManager.shared.retrieveImage(with: URL(string: LoginInfo.profile)!, options: [ .processor(processor),.requestModifier(APIManager.shared.imageDownloadRequest)]) { result in
            switch result {
            case .success(let result):
                completion(result.image)
            case .failure(_):
                completion(UIImage(systemName: "person.fill")!)
            }
        }
    }

    private func presentPickerView() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1

        if #available(iOS 16.0, *) {
            configuration.filter = .any(of: [.images, .depthEffectPhotos, .livePhotos])
        } else {
            configuration.filter = .images
        }

        let picker = PHPickerViewController(configuration: configuration)
        picker.modalPresentationStyle = .fullScreen
        picker.delegate = self

        present(picker, animated: true)
    }

    private func checkPermission() {
        PermissionManager.checkPhotoLibraryPermission { value in
            if value {
                self.presentPickerView()
            } else {
                self.present(PermissionManager.showRequestPhotoLibraryAlert(), animated: true)
            }
        }
    }

}

extension TabBarController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let itemProvider = results.first?.itemProvider
        if let itemProvider,
           itemProvider
            .hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            itemProvider
                .loadDataRepresentation(
                    forTypeIdentifier: UTType.image.identifier,
                    completionHandler: { [weak self] data, error in
                        guard let data,
                              let image = UIImage(data: data)
                        else { return }

                        image.resizeImage(toTargetSizeMB: 1) { image in
                            guard let image = image, let data = image.jpegData(compressionQuality: 1) else { return }

                            DispatchQueue.main.async {
                                let vc = PostViewController(viewModel: .init(data: data, size: image.size))
                                let view = UINavigationController(rootViewController: vc)
                                view.modalPresentationStyle = .fullScreen

                                picker.dismiss(animated: true) {
                                    self?.present(view, animated: true)
                                }
                            }
                        }

                    })
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
