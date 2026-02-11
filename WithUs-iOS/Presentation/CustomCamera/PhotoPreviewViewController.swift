//
//  PhotoPreviewViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/15/26.
//

import UIKit
import Photos
import SnapKit
import Then

protocol PhotoPreviewDelegate: AnyObject {
    func photoPreview(_ viewController: PhotoPreviewViewController, didSelectImage image: UIImage)
}

class PhotoPreviewViewController: BaseViewController {
    
    weak var delegate: PhotoPreviewDelegate?
    var dismissCamera: (() -> Void)?
    private let originalImage: UIImage
    private var editedImage: UIImage
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 24
        $0.clipsToBounds = true
        $0.isUserInteractionEnabled = true
    }
    
    private let saveButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_downLoad"), for: .normal)
    }
    
    private let editButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_edit"), for: .normal)
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .white
    }
    
    private let sendButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_sendButton"), for: .normal)
    }
    
    private let retakeButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_camera_back"), for: .normal)
    }
    
    private let loadingIndicator = UIActivityIndicatorView().then {
        $0.style = .large
        $0.color = .white
        $0.hidesWhenStopped = true
    }

    private let loadingDimView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.isHidden = true
    }
    
    init(image: UIImage) {
        self.originalImage = image
        self.editedImage = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = editedImage
    }
    
    override func setupUI() {
        view.backgroundColor = .black
        view.addSubview(imageView)
        view.addSubview(saveButton)
        view.addSubview(editButton)
        view.addSubview(closeButton)
        view.addSubview(sendButton)
        view.addSubview(retakeButton)
        view.addSubview(loadingDimView)
        loadingDimView.addSubview(loadingIndicator)
    }
    
    override func setupConstraints() {
        closeButton.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.size.equalTo(24)
        }
        
        saveButton.snp.makeConstraints {
            $0.top.right.equalTo(view.safeAreaLayoutGuide).inset(24)
            $0.size.equalTo(24)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(124)
            $0.left.right.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(imageView.snp.width)
        }
        
        sendButton.snp.makeConstraints {
            $0.size.equalTo(82)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        retakeButton.snp.makeConstraints {
            $0.size.equalTo(42)
            $0.left.equalTo(view.safeAreaLayoutGuide).offset(34)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(49)
        }
        
        editButton.snp.makeConstraints {
            $0.size.equalTo(42)
            $0.right.equalTo(view.safeAreaLayoutGuide).inset(34)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(49)
        }
        
        loadingDimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func setupActions() {
        saveButton.addTarget(self, action: #selector(savePhoto), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editPhoto), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
        retakeButton.addTarget(self, action: #selector(retakePhoto), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendPhoto), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func savePhoto() {
        captureEditedImage()
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else {
                return
            }
            
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(self.editedImage, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        DispatchQueue.main.async { [weak self] in
            if let error = error {
                self?.showAlert(title: "저장 실패", message: error.localizedDescription)
            } else {
                self?.showAlert(title: "저장 완료", message: "사진이 앨범에 저장되었습니다.")
            }
        }
    }
    
    @objc private func editPhoto() {
        let bottomSheet = EditBottomSheetViewController()
        bottomSheet.delegate = self
        bottomSheet.modalPresentationStyle = .overFullScreen
        bottomSheet.modalTransitionStyle = .crossDissolve
        present(bottomSheet, animated: false)
    }
    
    @objc private func retakePhoto() {
        dismiss(animated: true)
    }
    
    @objc private func sendPhoto() {
        captureEditedImage()
        delegate?.photoPreview(self, didSelectImage: editedImage)
        loadingDimView.isHidden = false
        loadingIndicator.startAnimating()
        sendButton.isEnabled = false
    }
    
    func showUploadSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            loadingDimView.isHidden = true
            loadingIndicator.stopAnimating()
            sendButton.isEnabled = true
            
            self.sendButton.setImage(UIImage(named: "ic_sendOkButton"), for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.dismiss(animated: true) {
                    self?.dismissCamera?()
                }
            }
        }
    }
    
    func showUploadFail() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.loadingDimView.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.sendButton.isEnabled = true
            ToastView.show(message: "업로드에 실패했어요", icon: nil, position: .bottom)
        }
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "사진 접근 권한 필요",
            message: "사진을 저장하려면 권한이 필요합니다.",
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
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    private func addTextToImage() {
        let alert = UIAlertController(title: "텍스트 추가", message: "추가할 텍스트를 입력하세요", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "텍스트 입력"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "추가", style: .default) { [weak self] _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                self?.createEditableText()
            }
        })
        
        present(alert, animated: true)
    }
    
    private func createEditableText() {
        let textView = EditableTextView(text: "텍스트")
        textView.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        textView.delegate = self
        imageView.addSubview(textView)
        textView.startEditing()
    }
    
    private func createDraggableSticker(image: UIImage) {
        let stickerView = DraggableStickerView(image: image)
        stickerView.center = CGPoint(x: imageView.bounds.midX, y: imageView.bounds.midY)
        stickerView.delegate = self
        
        imageView.addSubview(stickerView)
    }
    
    private func captureEditedImage() {
        let imageSize = originalImage.size
        let scale = imageSize.width / imageView.bounds.width
        
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        editedImage = renderer.image { context in
            originalImage.draw(at: .zero)
            
            for subview in imageView.subviews {
                context.cgContext.saveGState()
                
                let subviewCenter = subview.center
                let scaledCenter = CGPoint(x: subviewCenter.x * scale, y: subviewCenter.y * scale)
                
                context.cgContext.translateBy(x: scaledCenter.x, y: scaledCenter.y)
                
                context.cgContext.concatenate(subview.transform)
                context.cgContext.scaleBy(x: scale, y: scale)
                
                context.cgContext.translateBy(x: -subview.bounds.width / 2, y: -subview.bounds.height / 2)
                
                subview.layer.render(in: context.cgContext)
                
                context.cgContext.restoreGState()
            }
        }
        
        print("✅ 편집된 이미지 캡처 완료: \(editedImage.size)")
    }
}

extension PhotoPreviewViewController: EditBottomSheetDelegate {
    func didSelectText() {
        createEditableText()
    }
    
    func didSelectSticker(image: UIImage) {
        createDraggableSticker(image: image)
    }
}

extension PhotoPreviewViewController: DraggableViewDelegate {
    func draggableViewDidTap(_ view: UIView) {
        let alert = UIAlertController(title: nil, message: "삭제할까요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
            UIView.animate(withDuration: 0.2, animations: {
                view.alpha = 0
                view.transform = view.transform.scaledBy(x: 0.1, y: 0.1)
            }) { _ in
                view.removeFromSuperview()
                self.captureEditedImage()
            }
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    func draggableViewDidRequestDelete(_ view: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            view.alpha = 0
            view.transform = view.transform.scaledBy(x: 0.1, y: 0.1)
        }) { _ in
            view.removeFromSuperview()
            self.captureEditedImage()
        }
    }
}
