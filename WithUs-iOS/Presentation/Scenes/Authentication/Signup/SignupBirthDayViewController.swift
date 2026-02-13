//
//  SignupBirthDayViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/21/26.
//

import Foundation
import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class SignupBirthDayViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    
    weak var coordinator: SignUpCoordinator?
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textAlignment = .center
        $0.text = "생년월일을 입력해주세요"
        $0.textColor = UIColor.gray900
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textAlignment = .center
        $0.textColor = UIColor.gray500
        $0.text = "서로의 생일에 특별한 사진을 주고 받아요"
    }
    
    private let warningLabel = UILabel().then {
        $0.font = UIFont.pretendard14Regular
        $0.text = "올바른 생년월일을 입력해주세요."
        $0.textColor = UIColor.redWarning
        $0.isHidden = true
    }
    
    private let birthDayTextField = UITextField().then {
        $0.placeholder = "YYYY-MM-DD"
        $0.font = UIFont.pretendard18Regular
        $0.textAlignment = .center
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
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    init(reactor: SignUpReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
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
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        view.addSubview(birthDayTextField)
        view.addSubview(warningLabel)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.left.right.equalToSuperview()
        }
        
        birthDayTextField.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(birthDayTextField.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        birthDayTextField.delegate = self
        birthDayTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        let attributed = createHighlightedAttributedString(
            fullText: "2 / 3",
            highlightText: "2",
            highlightColor: UIColor(hex: "#EF4044"),
            normalColor: UIColor.gray900,
            font: UIFont.pretendard16SemiBold
        )
        setRightBarButton(attributedTitle: attributed)
    }
    
    func bind(reactor: SignUpReactor) {
        
    }
    
    func createHighlightedAttributedString(
        fullText: String,
        highlightText: String,
        highlightColor: UIColor,
        normalColor: UIColor,
        font: UIFont
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: font,
            .foregroundColor: normalColor
        ], range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttribute(.foregroundColor, value: highlightColor, range: nsRange)
        }
        
        return attributedString
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
        guard let text = birthDayTextField.text else { return }
        let isValid = validateBirthDate(text)
        
        if text.count == 10 {
            nextButton.isEnabled = isValid
            nextButton.backgroundColor = isValid ? UIColor.abled : UIColor.disabled
            warningLabel.isHidden = isValid
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.disabled
            warningLabel.isHidden = true
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let birthDate = birthDayTextField.text, !birthDate.isEmpty else { return }
        reactor?.action.onNext(.updateBirthDate(birthDate))
        coordinator?.showSignUpProfile()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
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

extension SignupBirthDayViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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
        textFieldDidChange()
        return false
    }
}
