//
//  CancleConnectViewController.swift
//  WithUs-iOS
//
//  Created on 1/27/26.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

final class CancleConnectViewController: BaseViewController, View {
    
    var disposeBag = DisposeBag()
    
    weak var coordinator: ProfileCoordinator?
    var onDisconnectComplete: (() -> Void)?
    
    private let profileView = ProfileImageView().then {
        $0.hideCameraButton()
        $0.isUserInteractionEnabled = false
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let nicknameValueLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let nicknamePaddingView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let birthDayLabel = UILabel().then {
        $0.text = "생년월일"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let birthDayValueLabel = UILabel().then {
        $0.text = "-"
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let birthDayPaddingView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 8
        $0.layer.borderColor = UIColor.gray200.cgColor
        $0.layer.borderWidth = 1
    }
    
    private let disconnectButton = UIButton().then {
        $0.setTitle("연결 해제하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
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
            string: "연결 정보",
            attributes: [
                .foregroundColor: UIColor.gray900,
                .font: UIFont.pretendard18SemiBold
            ]
        )
        navigationItem.titleView = UILabel().then {
            $0.attributedText = attributed
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(profileView)
        view.addSubview(nicknameLabel)
        view.addSubview(nicknamePaddingView)
        nicknamePaddingView.addSubview(nicknameValueLabel)
        
        view.addSubview(birthDayLabel)
        view.addSubview(birthDayPaddingView)
        birthDayPaddingView.addSubview(birthDayValueLabel)
        
        view.addSubview(disconnectButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.size.equalTo(134)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(40)
            $0.left.equalToSuperview().offset(16)
        }
        
        nicknamePaddingView.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        nicknameValueLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        birthDayLabel.snp.makeConstraints {
            $0.top.equalTo(nicknamePaddingView.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(16)
        }
        
        birthDayPaddingView.snp.makeConstraints {
            $0.top.equalTo(birthDayLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
        }
        
        birthDayValueLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        disconnectButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: ProfileReactor) {
        reactor.state
            .compactMap { $0.coupleInfo }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, user in
                strongSelf
                    .updateUI(
                        nickname: user.partnerProfile.nickname,
                        birthDate: user.partnerProfile.birthday,
                        profileImageURL: user.partnerProfile.profileImageUrl
                    )
            }
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
    
    private func updateUI(nickname: String, birthDate: String, profileImageURL: String?) {
        if !nickname.isEmpty {
            nicknameValueLabel.text = nickname
        }
        
        if !birthDate.isEmpty {
            birthDayValueLabel.text = birthDate
        }
        
        profileView.setProfileImage(profileImageURL)
    }
    
    @objc private func disconnectButtonTapped() {
        coordinator?.showCancleNotification(onDisconnectComplete: onDisconnectComplete)

    }
}

// MARK: - Data Model
struct PartnerInfo {
    let nickname: String
    let birthDate: String
    let profileImageURL: String?
}
