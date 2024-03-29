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
    private let commentLabel = UILabel()
    private let hashtagStackView = UIStackView()

    private let likeButtonDidTap = UITapGestureRecognizer()
    private let commentDidTap = UITapGestureRecognizer()

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

        viewModel.input.viewDidLoad.onNext(())
    }

    override func configHierarchy() {
        view.addSubview(profileStackView)
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nickname)
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(likedButton)
        view.addSubview(likeLabel)
        view.addSubview(commentLabel)
        view.addSubview(hashtagStackView)
    }

    override func setLayout() {

        profileStackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(8)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(profileStackView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.6)
        }

        hashtagStackView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(10)
            //$0.height.equalTo(30)
            $0.leading.equalToSuperview().inset(8)
        }

        likedButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.top.equalTo(hashtagStackView.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(8)
        }

        likeLabel.snp.makeConstraints {
            $0.top.equalTo(hashtagStackView.snp.bottom).offset(5)
            $0.trailing.equalToSuperview().inset(8)
        }

        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(8)
            $0.top.equalTo(likedButton.snp.bottom).offset(10)
        }

        profileImageView.snp.makeConstraints {
            $0.size.equalTo(40)
        }

        commentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(8)
        }

    }

    private func bind() {

        likeButtonColor
            .bind(to: likedButton.rx.tintColor)
            .disposed(by: disposeBag)

        likeButtonDidTap.rx.event
            .map { _ in () }
            .bind(to: viewModel.input.likeButtonDidTap)
            .disposed(by: disposeBag)

        commentDidTap.rx.event
            .asDriver()
            .drive(with: self) { owner, _ in
                let vc = CommentViewController(viewModel: .init(id: owner.viewModel.id), delegate: self)
                vc.modalPresentationStyle = .pageSheet
                vc.sheetPresentationController?.detents = [.medium(), .large()]
                vc.sheetPresentationController?.prefersGrabberVisible = true

                owner.present(vc, animated: true)
            }
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

        viewModel.output.commentCount
            .bind(to: commentLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.hashtags
            .bind(with: self) { owner, list in
                owner.setHashtag(list)
            }
            .disposed(by: disposeBag)
    }

    private func configure() {
        profileStackView.axis = .horizontal
        profileStackView.alignment = .center
        profileStackView.distribution = .fill
        profileStackView.spacing = 8
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor.main.cgColor
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        likedButton.isUserInteractionEnabled = true
        likedButton.addGestureRecognizer(likeButtonDidTap)
        titleLabel.font = .boldSystemFont(ofSize: 17)
        commentLabel.textColor = .gray
        commentLabel.isUserInteractionEnabled = true
        commentLabel.addGestureRecognizer(commentDidTap)
        hashtagStackView.axis = .horizontal
        hashtagStackView.alignment = .leading
        hashtagStackView.spacing = 4

        let backBarButton = UIBarButtonItem(image: UIImage(systemName: "multiply"), style: .plain, target: self, action: #selector(close))
        self.navigationItem.leftBarButtonItem = backBarButton

        navigationController?.navigationBar.tintColor = .main
    }

    private func setHashtag(_ list: [String]) {
        for item in list {
            let label = UILabel()
            label.text = " \(item) "
            label.backgroundColor = .main
            label.layer.cornerRadius = 7
            label.textColor = .white
            label.sizeToFit()
            label.clipsToBounds = true
            hashtagStackView.addArrangedSubview(label)
        }
    }

    @objc
    private func close() {
        dismiss(animated: true)
    }

}

extension DetailViewController: CommentViewDismissDelegate {
    func viewDismissed() {
        let viewWillAppearObservable = Observable<Void>.create { observer in
            observer.onNext(())
            return Disposables.create()
        }

        viewWillAppearObservable
            .bind(to: viewModel.input.viewWillAppear)
            .disposed(by: disposeBag)
    }
}

protocol CommentViewDismissDelegate: AnyObject {
    func viewDismissed()
}
