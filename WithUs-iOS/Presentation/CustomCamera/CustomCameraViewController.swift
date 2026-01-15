//
//  CustomCameraViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/15/26.
//

import UIKit
import AVFoundation
import Photos
import SnapKit
import Then

class CustomCameraViewController: BaseViewController {
    
    private var captureSession: AVCaptureSession?
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    
    private let containerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let previewView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
    }
    
    private let captureButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_capture"), for: .normal)
    }

    private let flipCameraButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_flip"), for: .normal)
    }
    
    private let flashButton = UIButton().then {
        $0.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        $0.tintColor = .white
    }
    
    private let galleryButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_album"), for: .normal)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
    }
    
    private var flashMode: AVCaptureDevice.FlashMode = .off
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.startRunning()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.captureSession?.stopRunning()
            }
        }
    }
    
    override func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(containerView)
        containerView.addSubview(previewView)
        containerView.addSubview(captureButton)
        containerView.addSubview(flipCameraButton)
        containerView.addSubview(flashButton)
        containerView.addSubview(galleryButton)
        containerView.addSubview(closeButton)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeButton.snp.makeConstraints {
            $0.top.left.equalTo(containerView.safeAreaLayoutGuide).inset(24)
            $0.size.equalTo(24)
        }
        
        flashButton.snp.makeConstraints {
            $0.top.right.equalTo(containerView.safeAreaLayoutGuide).inset(24)
            $0.size.equalTo(24)
        }
        
        previewView.snp.makeConstraints {
            $0.top.equalTo(containerView.safeAreaLayoutGuide).offset(124)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(previewView.snp.width) // 1:1 비율
        }
        
        captureButton.snp.makeConstraints {
            $0.size.equalTo(82)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide).inset(32)
        }
        
        flipCameraButton.snp.makeConstraints {
            $0.size.equalTo(42)
            $0.right.equalToSuperview().inset(34)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide).inset(49)
        }
        
        galleryButton.snp.makeConstraints {
            $0.size.equalTo(42)
            $0.left.equalToSuperview().offset(34)
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide).inset(49)
        }
    }
    
    override func setupActions() {
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        flipCameraButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "카메라 권한 필요",
            message: "카메라를 사용하려면 권한이 필요합니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
        
        guard let captureSession = captureSession else { return }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            print("카메라를 찾을 수 없습니다")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if let photoOutput = photoOutput, captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.setupPreviewLayer()
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
            
        } catch {
            print("카메라 설정 오류: \(error.localizedDescription)")
        }
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        videoPreviewLayer?.removeFromSuperlayer()
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill // 화면을 꽉 채우도록
        videoPreviewLayer?.frame = previewView.bounds
        
        if let videoPreviewLayer = videoPreviewLayer {
            previewView.layer.insertSublayer(videoPreviewLayer, at: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = previewView.bounds
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode
        
        photoOutput.capturePhoto(with: settings, delegate: self)
        
        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0
        view.addSubview(flashView)
        
        UIView.animate(withDuration: 0.1, animations: {
            flashView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.1, animations: {
                flashView.alpha = 0
            }) { _ in
                flashView.removeFromSuperview()
            }
        }
    }
    
    @objc private func flipCamera() {
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        captureSession?.stopRunning()
        
        guard let captureSession = captureSession else { return }
        
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        } catch {
            print("카메라 전환 오류: \(error.localizedDescription)")
        }
    }
    
    @objc private func toggleFlash() {
        switch flashMode {
        case .off:
            flashMode = .on
            flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
        case .on:
            flashMode = .auto
            flashButton.setImage(UIImage(systemName: "bolt.badge.automatic.fill"), for: .normal)
        case .auto:
            flashMode = .off
            flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        @unknown default:
            flashMode = .off
        }
    }
    
    @objc private func openGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    @objc private func closeCamera() {
        dismiss(animated: true)
    }
}

extension CustomCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        let croppedImage = image.cropToSquare()
        
        let previewVC = PhotoPreviewViewController(image: croppedImage)
        previewVC.modalPresentationStyle = .fullScreen
        present(previewVC, animated: true)
    }
}

extension CustomCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let image = info[.originalImage] as? UIImage {
            let croppedImage = image.cropToSquare()
            let previewVC = PhotoPreviewViewController(image: croppedImage)
            previewVC.modalPresentationStyle = .fullScreen
            present(previewVC, animated: true)
        }
    }
}
