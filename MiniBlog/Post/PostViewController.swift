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

final class PostViewController: BaseViewController {

    private let disposeBag = DisposeBag()

    private let imageView = UIImageView()
    private let titleTextField = SignTextField(placeholderText: String(localized: "사진에 대해 설명해보세요"))
    private let addButton = SignButton(title: String(localized: "추가"))
    private let viewModel: PostViewModel

    init(viewModel: PostViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
    }

    override func configHierarchy() {
        view.addSubview(imageView)
        view.addSubview(titleTextField)
        view.addSubview(addButton)
    }

    override func setLayout() {

        imageView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalToSuperview().multipliedBy(0.6)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.height.equalTo(40)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }

        addButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.width.equalTo(70)
            $0.height.equalTo(50)
        }

    }

    private func configure() {
        imageView.layer.borderColor = UIColor.main.cgColor
        imageView.layer.borderWidth = 2
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFit
    }

    private func bind() {
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.input.title)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .bind(to: viewModel.input.addButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.picture
            .debug()
            .subscribe(with: self) { owner, data in
                owner.imageView.image = UIImage(data: data)
            }
            .disposed(by: disposeBag)
        
        viewModel.output.postResult
            .subscribe(with: self) { owner, value in
                if value {
                    owner.dismiss(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }

}

extension PostViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        let itemProvider = results.first?.itemProvider
        if let itemProvider, itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
            itemProvider.loadDataRepresentation(
                forTypeIdentifier: UTType.image.identifier,
                completionHandler: { [weak self] data, error in
                guard let data, let image = UIImage(data: data) else {
                    self?.showMessage(error?.localizedDescription ?? String(localized: "사진을 불러오지 못했습니다"))
                    self?.dismiss(animated: true)
                    return
                }

                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            })
        }
    }

}
