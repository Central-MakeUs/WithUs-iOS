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

final class LoginViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    
    weak var coordinator: AuthCoordinator?
    
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "withup_logo")
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "사진으로 이어지는,\n우리 둘만의 기록"
        $0.numberOfLines = 2
        $0.textAlignment = .left
        $0.textColor = UIColor.gray900
        $0.font = UIFont.pretendard24Regular
    }
    
    private let kakaoButton = UIButton().then {
        $0.setTitle("카카오로 시작하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
    }
    
    private let appleButton = UIButton().then {
        $0.setTitle("Apple로 시작하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
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
        view.addSubview(logoImageView)
        view.addSubview(buttonStackView)
        view.addSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(kakaoButton)
        buttonStackView.addArrangedSubview(appleButton)
    }
    
    override func setupConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.size.equalTo(CGSize(width: 100, height: 20))
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        kakaoButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        appleButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    override func setupActions() {
        kakaoButton.addTarget(self, action: #selector(kakaoButtonTapped), for: .touchUpInside)
        appleButton.addTarget(self, action: #selector(appleButtonTapped), for: .touchUpInside)
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
        
        reactor.state.compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func kakaoButtonTapped() {
        reactor?.action.onNext(.kakaoLogin)
    }
    
    @objc private func appleButtonTapped() {
        performLogin()
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
}
