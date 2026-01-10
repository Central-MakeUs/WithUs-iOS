//
//  SignUpNickNameViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/6/26.
//

import UIKit
import Then
import SnapKit

final class SignUpNickNameViewController: BaseViewController {
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "위더스에서 활동할 닉네임은?"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = .systemGray
        $0.text = "상대방에게 주로 불리는 애칭을 입력해도 좋아요"
    }
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요."
        $0.font = .systemFont(ofSize: 16, weight: .regular)
        $0.textAlignment = .center
        $0.borderStyle = .none
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor.systemGray6
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
//        $0.clearButtonMode = .whileEditing
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = .systemBlue
        $0.layer.cornerRadius = 12
        $0.isEnabled = false
        $0.alpha = 0.5
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupUI() {
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
        
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.left.right.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
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
    
    private func setupTextFieldDelegate() {
        nicknameTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration) {
            self.nextButton.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-keyboardHeight + self.view.safeAreaInsets.bottom - 20)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.nextButton.snp.updateConstraints {
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func textFieldDidChange() {
        let text = nicknameTextField.text ?? ""
        let isValid = !text.isEmpty && text.count >= 2
        
        nextButton.isEnabled = isValid
        nextButton.alpha = isValid ? 1.0 : 0.5
    }
    
    @objc private func nextButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else { return }
        // 다음 화면으로 이동하는 로직
        print("닉네임: \(nickname)")
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension SignUpNickNameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // 닉네임 최대 길이 제한 (예: 10자)
        return updatedText.count <= 10
    }
}

import SwiftUI

#if DEBUG
struct SignUpNickNameViewController_Previews: PreviewProvider {
    static var previews: some View {
        SignUpNickNameViewController()
            .toPreview()
    }
}
#endif
