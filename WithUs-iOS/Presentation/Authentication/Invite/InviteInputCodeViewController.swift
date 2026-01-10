//
//  InviteCodeViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import Then
import SnapKit

class InviteInputCodeViewController: BaseViewController {
    
    private let pinLength = 8
    private var pinCode: String = "" {
        didSet {
            updatePinDisplay()
            updateNextButton()
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "상대방에게 받은 코드를\n입력해 주세요"
        $0.textColor = UIColor.gray900
    }
    
    private let pinStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    private let hiddenTextField = UITextField().then {
        $0.keyboardType = .numberPad
        $0.isHidden = true
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("연결하기", for: .normal)
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    private let warningIcon = UIImageView().then {
        $0.image = UIImage(named: "ic_red_warning")
    }
    
    private let warningLabel = UILabel().then {
        $0.font = UIFont.pretendard14Regular
        $0.text = "초대코드를 다시 확인해주세요."
        $0.textColor = UIColor.redWarning
        $0.isHidden = true
    }
    
    private let warningStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .center
    }
    
    private var pinDigitViews: [PinDigitView] = []
    
    deinit {
         NotificationCenter.default.removeObserver(self)
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextField()
        setupTapGesture()
        setupKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hiddenTextField.becomeFirstResponder()
    }
    
    override func setupUI() {
        setupNavigationBar()
        view.addSubview(titleLabel)
        view.addSubview(pinStackView)
        for _ in 0..<pinLength {
            let digitView = PinDigitView()
            pinDigitViews.append(digitView)
            pinStackView.addArrangedSubview(digitView)
        }
        view.addSubview(hiddenTextField)
        view.addSubview(warningStackView)
        
        warningStackView.addArrangedSubview(warningIcon)
        warningStackView.addArrangedSubview(warningLabel)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.centerX.equalToSuperview()
        }
        
        pinStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(64)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(75)
        }
        
        warningStackView.snp.makeConstraints {
            $0.top.equalTo(pinStackView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        warningIcon.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .black
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupTextField() {
        hiddenTextField.delegate = self
        hiddenTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func viewTapped() {
        hiddenTextField.becomeFirstResponder()
    }
    
    @objc private func textFieldDidChange() {
        guard let text = hiddenTextField.text else { return }
        let filtered = text.filter { $0.isNumber }
        if filtered.count <= pinLength {
            pinCode = filtered
            hiddenTextField.text = filtered
        } else {
            let truncated = String(filtered.prefix(pinLength))
            pinCode = truncated
            hiddenTextField.text = truncated
        }
        if pinCode.count == pinLength {
            handlePinComplete()
        }
    }
    
    private func updatePinDisplay() {
        let digits = Array(pinCode)
        
        for (index, digitView) in pinDigitViews.enumerated() {
            if index < digits.count {
                let digit = String(digits[index])
                digitView.configure(isFilled: true, digit: digit)
            } else {
                digitView.configure(isFilled: false, digit: nil)
            }
        }
    }
    
    private func updateNextButton() {
        let isValid = pinCode.count == pinLength
        nextButton.isEnabled = isValid
        nextButton.backgroundColor = isValid ? UIColor.abled : UIColor.disabled
    }
    
    private func handlePinComplete() {
        hiddenTextField.resignFirstResponder()
    }
}

extension InviteInputCodeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}

//import SwiftUI
//
//#if DEBUG
//struct PinInputViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        PinInputViewController()
//            .toPreview()
//    }
//}
//#endif

