//
//  PostViewModel.swift
//  MiniBlog
//
//  Created by 박다혜 on 11/30/23.
//

import Foundation
import CoreML
import CoreImage
import RxSwift

final class PostViewModel: ViewModelType {

    var disposeBag = DisposeBag()

    let input: Input
    let output: Output

    private let addButtonTap = PublishSubject<Void>()
    private let title = PublishSubject<String>()
    private let picture: BehaviorSubject<Data>
    private let width: CGFloat
    private let height: CGFloat
    private var hashtag = ""

    private let postResult = BehaviorSubject(value: false)

    struct Input {
        let addButtonTap: AnyObserver<Void>
        let title: AnyObserver<String>
        let picture: AnyObserver<Data>
    }

    struct Output {
        let picture: Observable<Data>
        let postResult: Observable<Bool>
    }

    init(data: Data, size: CGSize) {
        self.picture = .init(value: data)
        self.width = size.width
        self.height = size.height

        input = .init(
            addButtonTap: addButtonTap.asObserver(),
            title: title.asObserver(),
            picture: picture.asObserver()
        )

        output = .init(
            picture: picture.asObservable(),
            postResult: postResult.asObservable()
        )

        picture
            .subscribe(with: self) { owner, data in
                guard let image = CIImage(data: data) else {
                    return
                }
                owner.detect(image)
            }
            .disposed(by: disposeBag)

        addButtonTap
            .withLatestFrom(Observable.combineLatest(title, picture))
            .flatMapLatest { [weak self] title, picture in
                APIManager.shared.post(Post(title: title, file: picture, width: "\(self?.width ?? 0.0)", height: "\(self?.height ?? 0.0)", hashtag: self?.hashtag ?? ""))
                    .catchAndReturn(Response(message: "실패", isSuccess: false))
            }
            .subscribe(with: self) { owner, result in
                owner.postResult.onNext(result.isSuccess)
            }
            .disposed(by: disposeBag)

    }

}

extension PostViewModel {

    private func detect(_ image: CIImage) {

        guard let model = try? yolov8m_cls() else {
            fatalError("Loading CoreML Model Failed")
        }

        guard let buffer = resize(image: image) else {
            fatalError("Image Convert Failed")
        }

        do {
            let prediction = try model.prediction(image: buffer)
            let list = convertToArray(from: prediction.var_517)

            for item in list {
                if item > 0.6 {
                    let name = ModelDictionary().getItem(list.firstIndex(of: item) ?? 0)
                    hashtag.append("#\(name) ")
                }
            }

        } catch {

        }
    }

    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {

        // Init our output array
        var array: [Double] = []

        // Get length
        let length = mlMultiArray.count

        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            array.append(Double(truncating: mlMultiArray[[0,NSNumber(value: i)]]))
        }

        return array
    }

    func resize(image: CIImage) -> CVPixelBuffer? {
        let ModelInputWidth = 224
        let ModelInputHeight = 224

        var resizedPixelBuffer: CVPixelBuffer?
        CVPixelBufferCreate(nil, ModelInputWidth, ModelInputHeight, kCVPixelFormatType_32BGRA, nil, &resizedPixelBuffer)

        let sx = CGFloat(ModelInputWidth) / height
        let sy = CGFloat(ModelInputHeight) / width
        let scaleTransform = CGAffineTransform(scaleX: sx, y: sy)
        let scaledImage = image.transformed(by: scaleTransform)

        CIContext().render(scaledImage, to: resizedPixelBuffer!)

        return resizedPixelBuffer
    }

}
