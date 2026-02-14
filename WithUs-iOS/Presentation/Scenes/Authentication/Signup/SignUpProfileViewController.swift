//
//  SignUpProfileViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit
import Photos
import AVFoundation
import RxSwift
import RxCocoa
import ReactorKit
import Kingfisher

final class SignUpProfileViewController: BaseViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    weak var coordinator: SignUpCoordinator?
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.text = "프로필 사진을 등록해주세요."
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "사진을 등록하지 않으면 기본 프로필이 보여집니다."
    }
    
    private let profileView = ProfileImageView()
    
    private let nextButton = UIButton().then {
        $0.setTitle("프로필 완성하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
    }
    
    init(reactor: SignUpReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        let attributed = createHighlightedAttributedString(
            fullText: "3 / 3",
            highlightRange: NSRange(location: 0, length: 1),
            highlightColor: UIColor(hex: "#EF4044"),
            normalColor: UIColor.gray900,
            font: UIFont.pretendard16SemiBold
        )
        setRightBarButton(attributedTitle: attributed)
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        view.addSubview(profileView)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.left.right.equalToSuperview()
        }
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleStackView.snp.bottom).offset(42)
            $0.size.equalTo(134)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        profileView.delegate = self
    }
    
    func bind(reactor: SignUpReactor) {
        reactor.state.map { $0.isCompleted }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.coordinator?.didCompleteSignUp()
            })
            .disposed(by: disposeBag)
        
        reactor.state.compactMap { $0.user }
            .map { $0.profileImageUrl }
            .subscribe(onNext: { [weak self] url in
                self?.setImage(url)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { strongSelf, isLoading in
                isLoading ? strongSelf.showLoading() : strongSelf.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func nextBtnTapped() {
        reactor?.action.onNext(.completeProfile)
    }
    
    func createHighlightedAttributedString(
        fullText: String,
        highlightRange: NSRange,
        highlightColor: UIColor,
        normalColor: UIColor,
        font: UIFont
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: font,
            .foregroundColor: normalColor
        ], range: NSRange(location: 0, length: fullText.count))
        
        attributedString.addAttribute(.foregroundColor, value: highlightColor, range: highlightRange)
        
        return attributedString
    }
    
    private func setImage(_ url: String?) {
        profileView.setProfileImage(url)
    }
}

extension SignUpProfileViewController: ProfileViewDelegate {
    func setProfileTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "카메라", style: .default) { [weak self] _ in
            self?.openCamera()
        }
        
        let albumAction = UIAlertAction(title: "앨범", style: .default) { [weak self] _ in
            self?.openPhotoLibrary()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(albumAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
}

extension SignUpProfileViewController {
    private func openCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            presentPicker(sourceType: .camera)
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.presentPicker(sourceType: .camera)
                    }
                }
            }
            
        default:
            showPermissionAlert("카메라")
        }
    }
    
    private func openPhotoLibrary() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            presentPicker(sourceType: .photoLibrary)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.presentPicker(sourceType: .photoLibrary)
                    }
                }
            }
            
        default:
            showPermissionAlert("사진")
        }
    }
    
    private func presentPicker(sourceType: UIImagePickerController.SourceType) {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    private func showPermissionAlert(_ type: String) {
        let alert = UIAlertController(
            title: "\(type) 접근 권한 필요",
            message: "설정에서 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
}

extension SignUpProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        reactor?.action.onNext(.selectImage(imageData))
        profileView.configure(with: image)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
