//
//  TextInputViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit
import ReactorKit
import RxSwift
import Kingfisher

protocol TextInputViewControllerDelegate: AnyObject {
    func didUploadSuccess()
}

class TextInputViewController: BaseViewController, View {
    weak var delegate: TextInputViewControllerDelegate?
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: FourCutCoordinator?
    var selectedPhotos: [UIImage] = []
    var selectedFrameColor: FrameColorType = .white {
        didSet { updateFrameColor() }
    }
    private var customText: String = ""
    
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 1.83
    }
    
    private let bottomBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let dateLabel = UILabel().then {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        $0.text = dateFormatter.string(from: Date())
        $0.textColor = .black
        $0.font = UIFont.didot(size: 34.76, isRegular: false)
        $0.isUserInteractionEnabled = true
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.gray50
    }
    
    private let textBtn = UIButton().then {
        $0.setTitle("문구 다시 작성하기", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = UIColor.gray50
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let listBtn = UIButton().then {
        $0.setTitle("추억 생성하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 6
        $0.alignment = .center
        $0.backgroundColor = UIColor.gray50
    }
    
    private var photoImageViews: [UIImageView] = []
    
    private let profileLabel = UILabel().then {
        $0.text = "by"
        $0.textColor = .black
        $0.font = UIFont.didot(size: 14.63, isRegular: true)
    }
    
    private let myProfileImageView = ProfileDisplayView()
    
    private let partnerProfileImageView = ProfileDisplayView()
    
    private let coupleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 1.83
        $0.alignment = .center
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.gray50
        setupGridWithStackView()
        displayPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setNavigation() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        setRightBarButton(
            image: image,
            action: #selector(closeButtonTapped),
            tintColor: .black
        )
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "문구 작성", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        setLeftBarButton(image: UIImage(systemName: "chevron.left", withConfiguration: config))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(frameContainerView)
        view.addSubview(containerView)
        
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(dateLabel)
        bottomBar.addSubview(profileLabel)
        bottomBar.addSubview(coupleStackView)
        
        coupleStackView.addArrangedSubview(myProfileImageView)
        coupleStackView.addArrangedSubview(partnerProfileImageView)
        
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(textBtn)
        buttonStackView.addArrangedSubview(listBtn)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.height.equalTo(120)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        textBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        listBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(containerView.snp.top).offset(-8)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9.15)
            $0.leading.trailing.equalToSuperview().inset(5.49)
        }
        
        bottomBar.snp.makeConstraints {
            $0.top.equalTo(gridStackView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(9.15)
        }
        
        coupleStackView.snp.makeConstraints {
            $0.right.equalToSuperview().inset(9.15)
            $0.bottom.equalToSuperview().inset(18.29)
        }
        
        myProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        partnerProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        profileLabel.snp.makeConstraints {
            $0.right.equalTo(coupleStackView.snp.left).offset(-7.32)
            $0.bottom.equalToSuperview().inset(18.29)
        }
    }
    
    override func setupActions() {
        super.setupActions()
        textBtn.addTarget(self, action: #selector(dateLabelTapped), for: .touchUpInside)
        listBtn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
    }
    
    func bind(reactor: MemoryReactor) {
        reactor.state.compactMap { $0.uploadedImageUrl }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] imageUrl in
                self?.delegate?.didUploadSuccess()
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.coupleInfo }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, data in
                strongSelf.myProfileImageView.setProfileImage(data.meProfile.profileImageUrl)
                strongSelf.partnerProfileImageView.setProfileImage(data.partnerProfile.profileImageUrl)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                isLoading ? owner.showLoading() : owner.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.uploadErrorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupGridWithStackView() {
        for row in 0..<4 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 1.83
            
            for col in 0..<3 {
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                }
                
                imageView.snp.makeConstraints {
                    $0.width.equalTo(imageView.snp.height)
                }
                
                photoImageViews.append(imageView)
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    // MARK: - Display Photos
    
    private func displayPhotos() {
        for (index, imageView) in photoImageViews.enumerated() {
            if index < selectedPhotos.count {
                imageView.image = selectedPhotos[index]
            }
        }
    }
    
    private func updateFrameColor() {
        let backgroundColor = selectedFrameColor.backgroundColor
        let textColor = selectedFrameColor.textColor
        
        UIView.animate(withDuration: 0.3) {
            self.frameContainerView.backgroundColor = backgroundColor
            self.bottomBar.backgroundColor = backgroundColor
            self.dateLabel.textColor = textColor
            self.profileLabel.textColor = textColor
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        coordinator?.showUploadSuccessAndPopToRoot()
    }
    
    @objc private func dateLabelTapped() {
        let bottomSheet = TextInputBottomSheet()
        bottomSheet.currentText = customText.isEmpty ? getTodayDate() : customText
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        
        bottomSheet.onTextInput = { [weak self] text in
            self?.customText = text
            self?.dateLabel.text = text
        }
        
        present(bottomSheet, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        let finalImage = captureFrameAsImage()
        reactor?.action.onNext(.uploadImage(image: finalImage, title: dateLabel.text ?? ""))
    }
    
    private func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: Date())
    }
    
    // MARK: - Image Capture & Save
    
    private func captureFrameAsImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: frameContainerView.bounds)
        
        return renderer.image { context in
            frameContainerView.layer.render(in: context.cgContext)
        }
    }
    
    private func saveImageToPhotoLibrary(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            showAlert(title: "저장 실패", message: error.localizedDescription)
        } else {
            showAlert(title: "저장 완료", message: "사진이 앨범에 저장되었습니다.") {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

