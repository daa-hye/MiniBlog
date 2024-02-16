//
//  CommentViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/16/23.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentViewController: BaseViewController {

    let disposeBag = DisposeBag()

    let viewModel: CommentViewModel

    private weak var delegate: CommentViewDismissDelegate?

    lazy var listCollectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCommentLayout())

    let textField = UITextField()
    let placeholder = UILabel()

    let buttonConfig = {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .main
        config.title = String(localized: "게시")
        config.cornerStyle = .capsule
        return config
    }()

    lazy var confirmButton = UIButton(configuration: buttonConfig)

    var dataSource: UICollectionViewDiffableDataSource<Int, Comments>?

    init(viewModel: CommentViewModel, delegate: CommentViewDismissDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    deinit {
        delegate?.viewDismissed()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        bind()
        configureDataSource()

        let viewDidLoadObservable = Observable<Void>.create { observer in
            observer.onNext(())
            return Disposables.create()
        }

        viewDidLoadObservable
            .bind(to: viewModel.input.viewDidLoad)
            .disposed(by: disposeBag)
    }

    override func configHierarchy() {
        view.addSubview(listCollectionView)
        view.addSubview(textField)
        view.addSubview(placeholder)
    }

    override func setLayout() {
        textField.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(10)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-10)
            $0.height.equalTo(50)
        }

        listCollectionView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(textField.snp.top)
        }

        placeholder.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(40)
        }
    }

    func bind() {

        textField.rx.text.orEmpty
            .bind(to: viewModel.input.content)
            .disposed(by: disposeBag)

        confirmButton.rx.tap
            .bind(with: self, onNext: { owner, _ in
                owner.resignFirstResponder()
                owner.viewModel.input.writeComment.onNext(())
                owner.textField.text = nil
            })
            .disposed(by: disposeBag)

        viewModel.output.comments
            .subscribe(with: self) { owner, comments in
                var snapshot = NSDiffableDataSourceSnapshot<Int,Comments>()
                snapshot.appendSections([0])
                snapshot.appendItems(comments, toSection: 0)
                owner.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .disposed(by: disposeBag)

        viewModel.output.comments
            .map { $0.count != 0 }
            .subscribe(with: self) { owner, value in
                owner.placeholder.rx.isHidden.onNext(value)
            }
            .disposed(by: disposeBag)
    }

    private func configure() {
        textField.borderStyle = .roundedRect
        textField.placeholder = String(localized: "당신의 생각을 남겨주세요")
        textField.rightView = confirmButton
        textField.clearButtonMode = .never
        textField.rightViewMode = .whileEditing
        textField.keyboardType = .twitter
        placeholder.text = String(localized: "첫 댓글을 남겨주세요")
        placeholder.font = .systemFont(ofSize: 20)
        placeholder.textColor = .gray
        placeholder.textAlignment = .center
    }

}

extension CommentViewController {

    func configureCommentLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))

        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50))

        let group: NSCollectionLayoutGroup

        if #available(iOS 16.0, *) {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
        } else {
            group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        }

        group.interItemSpacing = .fixed(5)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        section.interGroupSpacing = 5

        let configure = UICollectionViewCompositionalLayoutConfiguration()
        configure.scrollDirection = .vertical

        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = configure

        return layout
    }

    func configureDataSource() {
        let cellRegistration = UICollectionView
            .CellRegistration<CommentCollectionViewCell, Comments> { cell, indexPath, itemIdentifier in

                cell.profileImageView.kf.setImage(
                    with: itemIdentifier.creator.profile,
                    options: [.requestModifier(APIManager.shared.imageDownloadRequest)]
                )
                cell.nicknameLabel.text = itemIdentifier.creator.nick
                cell.commentLabel.text = itemIdentifier.content
        }

        dataSource = UICollectionViewDiffableDataSource(
            collectionView: listCollectionView,
            cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        })
    }

}
