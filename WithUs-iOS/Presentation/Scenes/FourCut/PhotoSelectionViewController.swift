//
//  PhotoSelectionViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit
import Photos
import AVFoundation

class PhotoSelectionViewController: BaseViewController {
    
    weak var coordinator: FourCutCoordinator?
    private var selectedPhotos: [Int: UIImage] = [:]
    private var selectedImageViewIndex: Int?
    private var photoImageViews: [UIImageView] = []
    
    private let titleLabel = UILabel().then {
        $0.text = "사진을 선택해주세요"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let topBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    private let bottomBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let withusLabel = UILabel().then {
        $0.text = "WITHUS"
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGridWithStackView()
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
        setRightBarButton(
            image: UIImage(systemName: "checkmark"),
            action: #selector(checkButtonTapped),
            tintColor: .black
        )
        self.navigationItem.title = "2/4"
        setLeftBarButton(image: UIImage(systemName: "xmark"))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(titleLabel)
        view.addSubview(frameContainerView)
        
        frameContainerView.addSubview(topBar)
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(withusLabel)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        bottomBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(bottomBar.snp.top)
        }
        
        withusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func setupActions() {
        super.setupActions()
        
    }
    
    // MARK: - Setup Grid
    
    private func setupGridWithStackView() {
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6
            
            for col in 0..<2 {
                let index = row * 2 + col
                
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.isUserInteractionEnabled = true
                    $0.tag = index
                }
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
                imageView.addGestureRecognizer(tapGesture)
                
                photoImageViews.append(imageView)
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    @objc private func closeButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func checkButtonTapped() {
        let photos: [UIImage] = (0..<4).compactMap { selectedPhotos[$0] }
        coordinator?.showFilterSelection(photos)
    }
    
    @objc private func imageViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let imageView = gesture.view as? UIImageView else { return }
        selectedImageViewIndex = imageView.tag
        
        showPhotoSelectionOptions()
    }
    
    private func showPhotoSelectionOptions() {
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
        
        present(alert, animated: true, completion: nil)
    }
    
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
        picker.allowsEditing = false
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
    
//    private func updateImageViewBorders() {
//        for (index, imageView) in photoImageViews.enumerated() {
//            if index == selectedImageViewIndex {
//                imageView.layer.borderWidth = 2
//                imageView.layer.borderColor = UIColor.systemBlue.cgColor
//            } else {
//                imageView.layer.borderWidth = 1
//                imageView.layer.borderColor = UIColor.black.cgColor
//            }
//        }
//    }
    
    private func updateCheckButton() {
        let allPhotosFilled = selectedPhotos.count == 4
        navigationItem.rightBarButtonItem?.isEnabled = allPhotosFilled
    }
}

extension PhotoSelectionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        guard let selectedIndex = selectedImageViewIndex,
              let originalImage = info[.originalImage] as? UIImage else {
            return
        }
        
        selectedPhotos[selectedIndex] = originalImage
        photoImageViews[selectedIndex].image = originalImage
        
//        if let nextEmptyIndex = (0..<4).first(where: { selectedPhotos[$0] == nil }) {
//            selectedImageViewIndex = nextEmptyIndex
//        }
        updateCheckButton()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
