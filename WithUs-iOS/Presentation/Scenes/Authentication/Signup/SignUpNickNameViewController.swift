//
//  SignUpNickNameViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/6/26.
//

import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

final class SignUpNickNameViewController: BaseViewController, View {
    
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
        $0.text = "위더스에서 활동할 닉네임은?"
        $0.textColor = UIColor.gray900
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textAlignment = .center
        $0.textColor = UIColor.gray500
        $0.text = "상대방에게 주로 불리는 애칭을 입력해도 좋아요"
    }
    
    private let warningLabel = UILabel().then {
        $0.font = UIFont.pretendard14Regular
        $0.text = "2~8자로 입력해주세요."
        $0.textColor = UIColor.redWarning
        $0.isHidden = true
    }
    
    private let nicknameTextField = UITextField().then {
        $0.placeholder = "닉네임을 입력해주세요."
        $0.font = UIFont.pretendard18Regular
        $0.textAlignment = .center
        $0.borderStyle = .none
        $0.layer.cornerRadius = 8
        $0.backgroundColor = UIColor.gray100
        $0.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.leftViewMode = .always
        $0.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        $0.rightViewMode = .always
        $0.returnKeyType = .done
        $0.clearButtonMode = .whileEditing
    }
    
    private let nextButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
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
        let attributed = createHighlightedAttributedString(
            fullText: "1/4",
            highlightText: "1",
            highlightColor: UIColor(hex: "#EF4044"),
            normalColor: UIColor.gray900,
            font: UIFont.pretendard16SemiBold
        )
        setRightBarButton(attributedTitle: attributed)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.hidesBackButton = true
    }
    
    override func setupUI() {
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(warningLabel)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.left.right.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupActions() {
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
    
    private func setupTextFieldDelegate() {
        nicknameTextField.delegate = self
        nicknameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
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
        let isValid = text.count >= 2 && text.count <= 8
        
        nextButton.isEnabled = isValid
        nextButton.backgroundColor = isValid ? UIColor.abled : UIColor.disabled
        
        if text.isEmpty {
            warningLabel.isHidden = true
        } else {
            warningLabel.isHidden = isValid
        }
    }
    
    @objc private func nextButtonTapped() {
        guard let nickname = nicknameTextField.text, !nickname.isEmpty else { return }
        reactor?.action.onNext(.updateNickname(nickname))
        coordinator?.showSignBirthDay()
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
        return updatedText.count <= 10
    }
}
