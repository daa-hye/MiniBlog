//
//  ProfileEditViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 2/16/24.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa
import RxGesture

final class ProfileEditViewController: BaseViewController {
    
    private let profileImageView = UIImageView()
    private let profileEditView = UIView()
    private let cameraImage = UIImageView()
    private let nicknameTextField = UITextField()
    private let underLine = UIView()
    private let editButton = SignButton(title: String(localized: "완료"))

    private let viewModel: ProfileEditViewModel

    let disposeBag = DisposeBag()

    init(viewModel: ProfileEditViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configure()
        nicknameTextField.becomeFirstResponder()
    }

    private func bind() {

        profileEditView.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { owner, _ in
                owner.checkPermission()
            }
            .disposed(by: disposeBag)

        nicknameTextField.rx.text.orEmpty
            .bind(to: viewModel.input.newNickname)
            .disposed(by: disposeBag)

        viewModel.output.nickname
            .bind(to: nicknameTextField.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.profile
            .bind(with: self) { owner, url in
                owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
            }
            .disposed(by: disposeBag)

        editButton.rx.tap
            .bind(to: viewModel.input.editButtonDidTap)
            .disposed(by: disposeBag)

    }

    override func configHierarchy() {
        view.addSubview(profileImageView)
        view.addSubview(profileEditView)
        profileEditView.addSubview(cameraImage)
        view.addSubview(nicknameTextField)
        view.addSubview(underLine)
        view.addSubview(editButton)
    }

    override func setLayout() {

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(100)
        }

        profileEditView.snp.makeConstraints {
            $0.edges.equalTo(profileImageView)
            $0.size.equalTo(profileImageView)
        }

        cameraImage.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(55)
            $0.height.equalTo(40)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
        }

        underLine.snp.makeConstraints {
            $0.width.equalTo(nicknameTextField)
            $0.height.equalTo(1)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(1)
        }

        editButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-20)
        }
    }

    private func configure() {

        profileImageView.layer.cornerRadius = 50
        profileEditView.layer.cornerRadius = 50
        profileEditView.backgroundColor = .black.withAlphaComponent(0.4)
        cameraImage.image = UIImage(systemName: "camera.fill")
        cameraImage.tintColor = .white.withAlphaComponent(0.8)
        nicknameTextField.borderStyle = .none
        nicknameTextField.textAlignment = .center
        nicknameTextField.clearButtonMode = .whileEditing
        underLine.backgroundColor = .darkGray

    }

}

extension ProfileEditViewController {

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

extension ProfileEditViewController: PHPickerViewControllerDelegate {

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
                                self?.profileImageView.image = image
                                self?.profileImageView.layer.cornerRadius = 50
                                self?.viewModel.input.newProfile.onNext(data)
                                picker.dismiss(animated: true)
                            }
                        }

                    })
        }
    }

}
