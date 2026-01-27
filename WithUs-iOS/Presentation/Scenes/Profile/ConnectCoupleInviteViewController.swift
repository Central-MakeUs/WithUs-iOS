//
//  ConnectCoupleInviteViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class ConnectCoupleInviteViewController: BaseViewController {
    weak var coordinator: InviteCoordinatorProtocol?
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "상대방을 연결하고\n둘만의 추억을 쌓아가요."
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "아직 연결된 상대방이 없어요!"
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
    }
    
    private let inputCodeBtn = UIButton().then {
        $0.setTitle("상대방 코드 입력하기", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.backgroundColor = UIColor.gray50
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let inviteBtn = UIButton().then {
        $0.setTitle("내 코드로 초대하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
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
            string: "커플 연결 정보",
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
        view.addSubview(titleStackView)
        view.addSubview(imageView)
        view.addSubview(buttonStackView)
        
        titleStackView.addArrangedSubview(subTitleLabel)
        titleStackView.addArrangedSubview(titleLabel)
        
        buttonStackView.addArrangedSubview(inputCodeBtn)
        buttonStackView.addArrangedSubview(inviteBtn)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(52)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        inputCodeBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        inviteBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    
    override func setupActions() {
        inputCodeBtn.addTarget(self, action: #selector(inputCodeBtnTapped), for: .touchUpInside)
        inviteBtn.addTarget(self, action: #selector(inviteBtnTapped), for: .touchUpInside)
    }
    
    @objc private func inputCodeBtnTapped() {
        if let connectCoordinator = coordinator as? ConnectCoupleCoordinator {
            connectCoordinator.showInviteInputCode()
        } else {
            print("down castion error")
        }
    }
    
    @objc private func inviteBtnTapped() {
        if let connectCoordinator = coordinator as? ConnectCoupleCoordinator {
            connectCoordinator.showInviteCode()
        } else {
            print("down castion error")
        }
    }
}
