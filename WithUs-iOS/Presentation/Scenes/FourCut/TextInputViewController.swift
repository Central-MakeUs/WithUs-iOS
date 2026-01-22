//
//  TextInputViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit

class TextInputViewController: BaseViewController {
    
    // MARK: - Properties
    
    var selectedPhotos: [UIImage] = []
    var selectedFilter: PhotoFilterType = .original
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.text = "문구를 입력해 주세요"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let topBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let textField = UITextField().then {
        $0.placeholder = "문구를 입력하세요"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.attributedPlaceholder = NSAttributedString(
            string: "문구를 입력하세요",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    private let bottomBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let dateLabel = UILabel().then {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        $0.text = formatter.string(from: Date())
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    private let withusLabel = UILabel().then {
        $0.text = "WITHUS"
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("저장하기", for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
    }
    
    private var photoImageViews: [UIImageView] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGridWithStackView()
        displayPhotos()
        setupKeyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setNavigation() {
        setRightBarButton(image: UIImage(systemName: "checkmark"), tintColor: .clear)
        navigationItem.rightBarButtonItem?.isEnabled = false
        self.navigationItem.title = "4/4"
        setLeftBarButton(image: UIImage(systemName: "xmark"))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(titleLabel)
        view.addSubview(frameContainerView)
        view.addSubview(saveButton)
        
        frameContainerView.addSubview(topBar)
        topBar.addSubview(textField)
        
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        
        bottomBar.addSubview(dateLabel)
        bottomBar.addSubview(withusLabel)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            $0.height.equalTo(50)
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(saveButton.snp.top).offset(-40)
        }
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        textField.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
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
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
        
        withusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    override func setupActions() {
        super.setupActions()
        
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Setup Grid
    
    private func setupGridWithStackView() {
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6
            
            for col in 0..<2 {
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.layer.borderWidth = 1
                    $0.layer.borderColor = UIColor.black.cgColor
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
                let image = selectedPhotos[index]
                imageView.image = selectedFilter.apply(to: image)
            }
        }
    }
    
    // MARK: - Keyboard Handling
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        // 빈 화면 탭하면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        saveButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-keyboardHeight - 10)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        saveButton.snp.updateConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        // 최종 이미지 생성 및 저장
        let finalImage = captureFrameAsImage()
        saveImageToPhotoLibrary(finalImage)
    }
    
    @objc private func textFieldDidChange() {
        // 텍스트 입력 상태 체크 (선택사항)
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
                // 저장 후 처음 화면으로 돌아가기
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
