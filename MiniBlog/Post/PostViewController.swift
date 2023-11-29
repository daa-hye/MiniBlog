//
//  PostViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/27/23.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa

class PostViewController: BaseViewController {

    let disposeBag = DisposeBag()

    let titleTextField = SignTextField(placeholderText: String(localized: "사진에 대해 설명해보세요"))

    override func viewDidLoad() {
        super.viewDidLoad()

        PermissionManager.checkPhotoLibraryPermission { value in
            if value {
                self.presentPickerView()
            } else {
               
            }
        }
    }

}

extension PostViewController {

    func presentPickerView() {
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

}

extension PostViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        let itemProvider = results.first?.itemProvider
        if let itemProvider, itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier, completionHandler: { data, error in
                guard let data,
                      let jpegData = UIImage(data: data)?
                    .jpegData(compressionQuality: 0.1) else { return }
                APIManager.shared.post(Post(title: "test", file: jpegData, productId: "dahye"))
                    .subscribe(with: self) { owner, value in
                        print(value.message)
                    }
                    .disposed(by: self.disposeBag)
            })
        }
    }

}
