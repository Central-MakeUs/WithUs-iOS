//
//  AddKeywordBottomSheet.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

final class AddKeywordBottomSheet: BaseViewController {
    
    var onAddKeyword: ((String) -> Void)?
    private var isFirstAppear = true
    
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
        $0.text = "새로운 키워드 추가"
        $0.font = UIFont.pretendard18SemiBold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
    }
    
    private let textField = UITextField().then {
        $0.placeholder = "키워드를 입력하세요"
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray900
        $0.backgroundColor = UIColor.gray100
        $0.layer.cornerRadius = 8
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightViewMode = .always
        $0.returnKeyType = .done
    }
    
    private let addButton = UIButton().then {
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
        textField.becomeFirstResponder() // 여기서 키보드 올리기
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // animatePresentation 제거 - 키보드 애니메이션과 함께 자연스럽게 올라감
    }
    
    override func setupUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        view.addSubview(containerView)
        containerView.addSubview(handleBar)
        containerView.addSubview(titleLabel)
        containerView.addSubview(textField)
        containerView.addSubview(addButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.bottom) // 화면 밖에서 시작
            $0.height.equalTo(240)
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
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(52)
        }
    }
    
    override func setupActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        addButton.isEnabled = false
        addButton.backgroundColor = UIColor.disabled
        addButton.setTitleColor(UIColor.gray50, for: .normal)
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
                $0.height.equalTo(240)
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
                $0.height.equalTo(240)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func textFieldChanged() {
        let hasText = !(textField.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true)
        addButton.isEnabled = hasText
        addButton.backgroundColor = hasText ? UIColor.abled : UIColor.disabled
        addButton.setTitleColor(hasText ? .white : UIColor.gray50, for: .normal)
    }
    
    @objc private func addButtonTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty else { return }
        onAddKeyword?(text)
        dismiss(animated: true)
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        if flag {
            view.endEditing(true)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.containerView.snp.remakeConstraints {
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalTo(self.view.snp.bottom)
                    $0.height.equalTo(240)
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
extension AddKeywordBottomSheet: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}

// MARK: - UITextFieldDelegate
extension AddKeywordBottomSheet: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        addButtonTapped()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 20
    }
}
