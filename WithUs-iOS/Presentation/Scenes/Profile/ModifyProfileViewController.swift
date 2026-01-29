//
//  ModifyProfileViewController.swift
//  WithUs-iOS
//
//  Created on 1/27/26.
//

import UIKit
import SnapKit
import Then
import Photos
import AVFoundation
import ReactorKit
import RxSwift
import RxCocoa

final class ModifyProfileViewController: BaseViewController/*, View*/ {
    
    var disposeBag = DisposeBag()
    
    weak var coordinator: ProfileCoordinator?
    
    private let scrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
        $0.keyboardDismissMode = .interactive
    }
    
    private let contentView = UIView()
    
    private let profileView = ProfileImageView()
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요."
        $0.font = UIFont.pretendard18Regular
        $0.textAlignment = .left
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.gray100
        $0.textColor = UIColor.gray900
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
        $0.clearButtonMode = .whileEditing
    }
    
    private let nicknameWarningLabel = UILabel().then {
        $0.font = UIFont.pretendard14Regular
        $0.text = "2~8자로 입력해주세요."
        $0.textColor = UIColor.redWarning
        $0.isHidden = true
    }
    
    // 생년월일 섹션
    private let birthDayLabel = UILabel().then {
        $0.text = "생년월일"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let birthDayTextField = UITextField().then {
        $0.placeholder = "YYYY-MM-DD"
        $0.font = UIFont.pretendard18Regular
        $0.textAlignment = .left
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.gray100
        $0.textColor = UIColor.gray900
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
        $0.keyboardType = .numberPad
        $0.clearButtonMode = .never
    }
    
    private let birthDayWarningLabel = UILabel().then {
        $0.font = UIFont.pretendard14Regular
        $0.text = "올바른 생년월일을 입력해주세요."
        $0.textColor = UIColor.redWarning
        $0.isHidden = true
    }
    
    private let saveButton = UIButton().then {
        $0.setTitle("저장", for: .normal)
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
    }
    
    // MARK: - Properties
    private var selectedImage: UIImage?
    private var isNicknameValid = false
    private var isBirthDateValid = false
    
    init(reactor: ProfileReactor) {
        super.init(nibName: nil, bundle: nil)
//        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        setupGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        let attributed = NSAttributedString(
            string: "프로필 편집",
            attributes: [
                .foregroundColor: UIColor.gray900,
                .font: UIFont.pretendard18SemiBold
            ]
        )
        navigationItem.titleView = UILabel().then {
            $0.attributedText = attributed
        }
        
        let completeButton = UIBarButtonItem(
            title: "저장",
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
        completeButton.setTitleTextAttributes([
            .foregroundColor: UIColor.redWarning,
            .font: UIFont.pretendard16SemiBold
        ], for: .normal)
        completeButton.setTitleTextAttributes([
            .foregroundColor: UIColor.gray300,
            .font: UIFont.pretendard16SemiBold
        ], for: .disabled)
        completeButton.isEnabled = false
        navigationItem.rightBarButtonItem = completeButton
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(profileView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(nicknameTextField)
        contentView.addSubview(nicknameWarningLabel)
        contentView.addSubview(birthDayLabel)
        contentView.addSubview(birthDayTextField)
        contentView.addSubview(birthDayWarningLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(32)
            $0.size.equalTo(134)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(40)
            $0.left.equalToSuperview().offset(16)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        nicknameWarningLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
        }
        
        birthDayLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(16)
        }
        
        birthDayTextField.snp.makeConstraints {
            $0.top.equalTo(birthDayLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        birthDayWarningLabel.snp.makeConstraints {
            $0.top.equalTo(birthDayTextField.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    override func setupActions() {
        profileView.delegate = self
        nicknameTextField.delegate = self
        birthDayTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange), for: .editingChanged)
        birthDayTextField.addTarget(self, action: #selector(birthDateTextFieldDidChange), for: .editingChanged)
    }
    
//    func bind(reactor: ProfileReactor) {
//        reactor.state.map { $0.nickname }
//            .distinctUntilChanged()
//            .bind(to: nicknameTextField.rx.text)
//            .disposed(by: disposeBag)
//        
//        reactor.state.map { $0.birthDate }
//            .distinctUntilChanged()
//            .bind(to: birthDayTextField.rx.text)
//            .disposed(by: disposeBag)
//        
//        reactor.state.map { $0.profileImage }
//            .distinctUntilChanged()
//            .subscribe(onNext: { [weak self] imageData in
//                if let data = imageData, let image = UIImage(data: data) {
//                    self?.profileView.profileImageView.image = image
//                }
//            })
//            .disposed(by: disposeBag)
//    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let nickname = nicknameTextField.text,
              let birthDate = birthDayTextField.text else { return }
        
        // Reactor action 호출
        // reactor?.action.onNext(.updateProfile(nickname: nickname, birthDate: birthDate, image: selectedImage))
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func nicknameTextFieldDidChange() {
        let text = nicknameTextField.text ?? ""
        isNicknameValid = text.count >= 2 && text.count <= 8
        
        if text.isEmpty {
            nicknameWarningLabel.isHidden = true
        } else {
            nicknameWarningLabel.isHidden = isNicknameValid
        }
        
        updateSaveButtonState()
    }
    
    @objc private func birthDateTextFieldDidChange() {
        guard let text = birthDayTextField.text else { return }
        
        if text.count == 10 {
            isBirthDateValid = validateBirthDate(text)
            birthDayWarningLabel.isHidden = isBirthDateValid
        } else {
            isBirthDateValid = false
            birthDayWarningLabel.isHidden = true
        }
        
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let isValid = isNicknameValid && isBirthDateValid
        navigationItem.rightBarButtonItem?.isEnabled = isValid
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
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
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Birth Date Validation
    private func validateBirthDate(_ dateString: String) -> Bool {
        guard dateString.count == 10 else { return false }
        
        let components = dateString.split(separator: "-").map { String($0) }
        guard components.count == 3 else { return false }
        
        guard let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return false
        }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        guard year >= 1900 && year <= currentYear else { return false }
        
        guard month >= 1 && month <= 12 else { return false }
        
        let daysInMonth = numberOfDays(in: month, year: year)
        guard day >= 1 && day <= daysInMonth else { return false }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: dateString),
              date <= Date() else {
            return false
        }
        
        return true
    }
    
    private func numberOfDays(in month: Int, year: Int) -> Int {
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0) {
                return 29
            } else {
                return 28
            }
        default:
            return 0
        }
    }
    
    private func formatBirthDate(_ text: String) -> String {
        let digits = text.filter { $0.isNumber }
        
        var formatted = ""
        for (index, character) in digits.enumerated() {
            if index == 4 || index == 6 {
                formatted += "-"
            }
            formatted.append(character)
        }
        
        return formatted
    }
}

// MARK: - UITextFieldDelegate
extension ModifyProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameTextField {
            birthDayTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nicknameTextField {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= 10
        } else if textField == birthDayTextField {
            let allowedCharacters = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            
            if string.isEmpty {
                return true
            }
            
            guard allowedCharacters.isSuperset(of: characterSet) else {
                return false
            }
            
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            
            let digits = updatedText.filter { $0.isNumber }
            
            guard digits.count <= 8 else { return false }
            
            let formatted = formatBirthDate(digits)
            textField.text = formatted
            birthDateTextFieldDidChange()
            return false
        }
        
        return true
    }
}

// MARK: - ProfileViewDelegate
extension ModifyProfileViewController: ProfileViewDelegate {
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

// MARK: - Photo & Camera
extension ModifyProfileViewController {
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

// MARK: - UIImagePickerControllerDelegate
extension ModifyProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage else {
            return
        }
        
        selectedImage = image
        profileView.profileImageView.image = image
        // reactor?.action.onNext(.selectImage(image))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
