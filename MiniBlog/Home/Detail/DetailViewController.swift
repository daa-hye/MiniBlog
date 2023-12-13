//
//  DetailViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: BaseViewController {

    let viewModel: DetailViewModel

    let disposeBag = DisposeBag()

    private let profileStackView = UIStackView()
    private let profileImageView = UIImageView()
    private let nickname = UILabel()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let likedButton = UIImageView(image: UIImage(systemName: "heart.fill"))
    private let likeLabel = UILabel()

    private let likeButtonTap = UITapGestureRecognizer()

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let likeButtonColor = BehaviorSubject<UIColor>(value: .main)

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configure()

        let viewDidLoadObservable = Observable<Void>.create { observer in
            observer.onNext(())
            return Disposables.create()
        }

        viewDidLoadObservable
            .bind(to: viewModel.input.viewDidLoad)
            .disposed(by: disposeBag)
    }

    override func configHierarchy() {
        view.addSubview(profileStackView)
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nickname)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(likedButton)
        view.addSubview(likeLabel)
    }

    override func setLayout() {

        profileStackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(20)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(profileStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }

        likedButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(8)
        }

        likeLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            $0.trailing.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalTo(likedButton.snp.bottom).offset(20)
        }

        profileImageView.snp.makeConstraints {
            $0.size.equalTo(40)
        }

    }

    private func bind() {

        likeButtonColor
            .bind(to: likedButton.rx.tintColor)
            .disposed(by: disposeBag)

        likeButtonTap.rx.event
            .map { _ in () }
            .bind(to: viewModel.input.likeButtonTap)
            .disposed(by: disposeBag)

        viewModel.output.title
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.image
            .bind(with: self) { owner, url in
                owner.imageView.kf.setImage(with: url, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
            }
            .disposed(by: disposeBag)

        viewModel.output.nickname
            .bind(to: nickname.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.profile
            .bind(with: self) { owner, url in
                owner.profileImageView.kf.setImage(with: url, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
            }
            .disposed(by: disposeBag)

        viewModel.output.likeCount
            .bind(to: likeLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.liked
            .bind(with: self) { owner, value in
                value ? owner.likeButtonColor.onNext(.systemPink) : owner.likeButtonColor.onNext(.main)
            }
            .disposed(by: disposeBag)
    }

    private func configure() {
        profileStackView.axis = .horizontal
        profileStackView.alignment = .leading
        profileStackView.distribution = .fill
        profileStackView.spacing = 16
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.main.cgColor
        likedButton.isUserInteractionEnabled = true
        likedButton.addGestureRecognizer(likeButtonTap)
    }

}
