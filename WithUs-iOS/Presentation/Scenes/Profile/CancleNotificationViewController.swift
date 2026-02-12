//
//  CancleNotificationViewController.swift
//  WithUs-iOS
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift

final class CancleNotificationViewController: BaseViewController, ReactorKit.View {
    weak var coordinator: ProfileCoordinator?
    var onDisconnectComplete: (() -> Void)? // 연결 해제 완료 후 실행할 클로저
    var disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "-님과 연결을 해제할까요?"
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
    }
    
    private let profileView = ProfileImageView().then {
        $0.hideCameraButton()
        $0.isUserInteractionEnabled = false
    }
    
    private let warningTitleView = UIView()
    
    private let warningIconView = UIView().then {
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 10
    }
    
    private let warningIconLabel = UILabel().then {
        $0.text = "!"
        $0.font = UIFont.pretendard14SemiBold
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let warningTitleLabel = UILabel().then {
        $0.text = "연결 해제 전 꼭 확인해 주세요"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let warningDetail1StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon1 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private let warning1Label = UILabel().then {
        $0.text = "한 사람만 연결을 해제한 후 동일한 상대방과 다시 연결하는 경우, 데이터를 복구할 수 있어요."
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    private let warningDetail2StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon2 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private let warning2Label = UILabel().then {
        $0.text = "상대방도 연결을 해제하는 경우 데이터 복구가 불가능해요."
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    private let warningDetail3StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon3 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private let warning3Label = UILabel().then {
        $0.text = "연결을 해제한 후 새로운 사용자와 연결하는 경우,\n데이터 복구가 불가능해요"
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    private let warningStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .leading
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("유지하기", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let disconnectButton = UIButton().then {
        $0.setTitle("연결 해제하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
        $0.backgroundColor = UIColor.abled
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
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
            string: "연결 해제",
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
        
        view.addSubview(titleLabel)
        view.addSubview(profileView)
        view.addSubview(warningTitleView)
        
        warningTitleView.addSubview(warningIconView)
        warningIconView.addSubview(warningIconLabel)
        warningTitleView.addSubview(warningTitleLabel)
        
        warningDetail1StackView.addArrangedSubview(dotIcon1)
        warningDetail1StackView.addArrangedSubview(warning1Label)
        
        warningDetail2StackView.addArrangedSubview(dotIcon2)
        warningDetail2StackView.addArrangedSubview(warning2Label)
        
        warningDetail3StackView.addArrangedSubview(dotIcon3)
        warningDetail3StackView.addArrangedSubview(warning3Label)
        
        warningStackView.addArrangedSubview(warningDetail1StackView)
        warningStackView.addArrangedSubview(warningDetail2StackView)
        warningStackView.addArrangedSubview(warningDetail3StackView)
        
        view.addSubview(warningStackView)
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(disconnectButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(22)
            $0.centerX.equalToSuperview()
        }
        
        profileView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(167)
        }
        
        warningTitleView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        warningIconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        warningIconLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        warningTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(warningIconView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        warningStackView.snp.makeConstraints {
            $0.top.equalTo(warningTitleView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        warningDetail1StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        warningDetail2StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        warningDetail3StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        disconnectButton.addTarget(self, action: #selector(disconnectButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: ProfileReactor) {
        reactor.state.map { $0.cancleSuccess }
            .distinctUntilChanged()
            .filter({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showDisconnectSuccessAlert()
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.coupleInfo }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, user in
                if !user.partnerProfile.nickname.isEmpty {
                    strongSelf.titleLabel.text = "\(user.partnerProfile.nickname)님과 연결을 해제할까요?"
                    strongSelf.profileView.setProfileImage(user.partnerProfile.profileImageUrl)
                }
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
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func disconnectButtonTapped() {
        performDisconnect()
    }
    
    private func performDisconnect() {
        reactor?.action.onNext(.cancleConnect)
    }
    
    private func showDisconnectSuccessAlert() {
        let alert = UIAlertController(
            title: "연결이 해제되었습니다",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let onDisconnectComplete = self.onDisconnectComplete {
                // 회원 탈퇴 플로우: CancleConnectViewController까지 pop 후 다음 화면으로
                self.coordinator?.handleDisconnectAndWithdrawal(onComplete: onDisconnectComplete)
            } else {
                self.coordinator?.handleDisconnect()
            }
        })
        
        present(alert, animated: true)
    }
}
