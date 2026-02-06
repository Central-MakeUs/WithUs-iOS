//
//  TextInputBottomSheet.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import UIKit
import SnapKit
import Then

final class TextInputBottomSheet: BaseViewController {
    
    var onTextInput: ((String) -> Void)?
    var currentText: String = ""
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let handleBar = UIView().then {
        $0.backgroundColor = UIColor.gray300
        $0.layer.cornerRadius = 2.5
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "원하는 문구를 작성해보세요."
        $0.font = UIFont.pretendard18SemiBold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
    }
    
    private let textFieldContainer = UIView().then {
        $0.backgroundColor = UIColor.gray100
        $0.layer.cornerRadius = 8
    }
    
    private let textField = UITextField().then {
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
        $0.backgroundColor = .clear
        $0.returnKeyType = .done
        $0.textAlignment = .center
    }
    
    private let clearButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        $0.tintColor = UIColor.gray600
        $0.isHidden = true
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitle("추가하기", for: .normal)
        $0.backgroundColor = UIColor.abled
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.bold, size: 16)
        $0.layer.cornerRadius = 8
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardObservers()
        textField.delegate = self
        textField.text = currentText
        textField.becomeFirstResponder()
        updateClearButtonVisibility()
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(handleBar)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textFieldContainer)
        containerView.addSubview(confirmButton)
        
        textFieldContainer.addSubview(textField)
        textFieldContainer.addSubview(clearButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom)
            $0.height.equalTo(280)
        }
        
        handleBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(handleBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        textFieldContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(55)
        }
        
        textField.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalTo(clearButton.snp.leading).offset(-8)
        }
        
        clearButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15.5)
            $0.size.equalTo(24)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    // MARK: - Keyboard Observers
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
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut) {
            self.containerView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
                $0.height.equalTo(280)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.containerView.snp.remakeConstraints {
                $0.leading.trailing.equalToSuperview()
                $0.top.equalTo(self.view.snp.bottom)
                $0.height.equalTo(280)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func textFieldDidChange() {
        updateClearButtonVisibility()
    }
    
    @objc private func clearButtonTapped() {
        textField.text = ""
        updateClearButtonVisibility()
        textField.becomeFirstResponder()
    }
    
    private func updateClearButtonVisibility() {
        let hasText = !(textField.text?.isEmpty ?? true)
        clearButton.isHidden = !hasText
    }
    
    @objc private func confirmButtonTapped() {
        let text = textField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let finalText = text.isEmpty ? getTodayDate() : text
        onTextInput?(finalText)
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    private func getTodayDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        return dateFormatter.string(from: Date())
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            view.endEditing(true)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.containerView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalTo(self.view.snp.bottom)
                    $0.height.equalTo(280)
                }
                self.view.backgroundColor = .clear
                self.view.layoutIfNeeded()
            } completion: { _ in
                super.dismiss(animated: false, completion: completion)
            }
        } else {
            super.dismiss(animated: false, completion: completion)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension TextInputBottomSheet: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}

// MARK: - UITextFieldDelegate
extension TextInputBottomSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        confirmButtonTapped()
        return true
    }
}
