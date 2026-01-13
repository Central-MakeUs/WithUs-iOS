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

final class SignUpProfileViewController: BaseViewController {
    
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
    
    override func setupUI() {
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
    
    @objc private func nextBtnTapped() {
        coordinator?.showInvite()
    }
}

extension SignUpProfileViewController: ProfileViewDelegate {
    func setProfileTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let modifyAction = UIAlertAction(title: "수정", style: .default, handler: nil)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: nil)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(modifyAction)
        alert.addAction(deleteAction)
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
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized, .limited:
            presentPicker(sourceType: .photoLibrary)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
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
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        profileView.profileImageView.image = image
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
