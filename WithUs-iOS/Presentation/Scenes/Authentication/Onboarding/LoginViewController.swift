//
//  LoginViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa
import AuthenticationServices

final class LoginViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    
    weak var coordinator: AuthCoordinator?
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "login")
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "사진으로 이어지는,\n우리 둘만의 커플 이야기"
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.textColor = UIColor.gray900
        $0.font = UIFont.pretendard24Regular
    }
    
    private let kakaoButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "kakao")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.background.backgroundColor = UIColor(hex: "#FFE812")
        config.background.cornerRadius = 8  // ✅ layer 말고 여기서 설정
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        var titleAttr = AttributedString("카카오로 시작하기")
        titleAttr.font = UIFont.pretendard16SemiBold
        titleAttr.foregroundColor = UIColor.gray900
        config.attributedTitle = titleAttr
        $0.configuration = config
        $0.clipsToBounds = true
    }
    
    private let appleButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.cornerStyle = .fixed
        config.background.cornerRadius = 8
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.image = UIImage(systemName: "apple.logo")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
        var titleAttr = AttributedString("Apple로 시작하기")
        titleAttr.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleAttr.foregroundColor = UIColor.white
        config.attributedTitle = titleAttr
        $0.configuration = config
        $0.isUserInteractionEnabled = false
        $0.clipsToBounds = true  // ✅ 추가
    }

    let appleCustomButton = ASAuthorizationAppleIDButton(
        authorizationButtonType: .signIn,
        authorizationButtonStyle: .black
    ).then {
        $0.cornerRadius = 8
        $0.alpha = 0.011
    }

    private let appleLoginContainer = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    init(reactor: LoginReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(imageView)
        view.addSubview(buttonStackView)
        view.addSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(kakaoButton)
        buttonStackView.addArrangedSubview(appleLoginContainer)

        appleLoginContainer.addSubview(appleButton)
        appleLoginContainer.addSubview(appleCustomButton)
    }
    
    override func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(77)
            $0.size.equalTo(343)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-54)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-24)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        appleLoginContainer.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }

        appleCustomButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().priority(.high)
            $0.centerX.equalToSuperview()
        }

        appleButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setupActions() {
        kakaoButton.addTarget(self, action: #selector(kakaoButtonTapped), for: .touchUpInside)
        appleCustomButton.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: LoginReactor) {
        reactor.state.compactMap { $0.loginResult }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                guard let self else { return }
                switch status {
                case .needUserSetup:
                    self.coordinator?.showSignup()
                default:
                    self.coordinator?.didLogin()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { strongSelf, isLoading in
                isLoading ? strongSelf.showLoading() : strongSelf.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func kakaoButtonTapped() {
        reactor?.action.onNext(.kakaoLogin)
    }
    
    @objc private func appleButtonTapped() {
        startAppleLogin()
    }
    
    private func performLogin() {
        self.coordinator?.showSignup()
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "알림",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func startAppleLogin() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            return
        }
        
        guard
            let identityToken = credential.identityToken,
            let authorizationCode = credential.authorizationCode,
            let identityTokenString = String(data: identityToken, encoding: .utf8),
            let authorizationCodeString = String(data: authorizationCode, encoding: .utf8)
        else {
            reactor?.action.onNext(.appleLogin(identityToken: "", authorizationCode: ""))
            return
        }
        let appleUserIdentifier = credential.user
        let fullName = credential.fullName
        let email = credential.email
        UserManager.shared.appleUserIdentifier = appleUserIdentifier
        if let email = email {
            UserManager.shared.email = email
        }
        if let familyName = fullName?.familyName,
            let givenName = fullName?.givenName {
            UserManager.shared.fullName = familyName + givenName
        }
        print("identityTokenString: \(identityTokenString)")
        print("authorizationCodeString: \(authorizationCodeString)")
        reactor?.action.onNext(.appleLogin(identityToken: identityTokenString, authorizationCode: authorizationCodeString))
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        reactor?.action.onNext(.appleLogin(identityToken: "", authorizationCode: ""))
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(
        for controller: ASAuthorizationController
    ) -> ASPresentationAnchor {
        view.window!
    }
}


