//
//  DetailViewController.swift
//  MiniBlog
//
//  Created by 박다혜 on 12/11/23.
//

import UIKit
import RxSwift
import RxCocoa

class DetailViewController: BaseViewController {

    let viewModel: DetailViewModel

    let disposeBag = DisposeBag()

    let imageView = UIImageView()
    let titleLabel = UILabel()

    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bind()

        let viewDidLoadObservable = Observable<Void>.create { observer in
            observer.onNext(())
            return Disposables.create()
        }

        viewDidLoadObservable
            .bind(to: viewModel.input.viewDidLoad)
            .disposed(by: disposeBag)
    }

    override func configHierarchy() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
    }

    override func setLayout() {

        titleLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview().inset(16)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalToSuperview().multipliedBy(0.6)
        }

    }

    func bind() {

        viewModel.output.data
            .map {$0.title}
            .bind(to: titleLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.output.data
            .map { $0.image }
            .bind(with: self) { owner, url in
                owner.imageView.kf.setImage(with: url, options: [.requestModifier(APIManager.shared.imageDownloadRequest)])
            }
            .disposed(by: disposeBag)

    }


}
