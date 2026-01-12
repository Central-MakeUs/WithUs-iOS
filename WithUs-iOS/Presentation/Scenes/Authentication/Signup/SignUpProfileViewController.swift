//
//  SignUpProfileViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit

final class SignUpProfileViewController: BaseViewController {
    
    weak var coordinator: SignUpCoordinator?
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.text = "프로필 사진을 등록해주세요."
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "사진을 등록하지 않으면 기본 프로필이 보여집니다."
    }
    
    private let profileView = ProfileImageView()
    
    private let nextButton = UIButton().then {
        $0.setTitle("프로필 완성하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isEnabled = true
    }
    
    override func setupUI() {
        view.addSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        view.addSubview(profileView)
        view.addSubview(nextButton)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.left.right.equalToSuperview()
        }
        
        profileView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleStackView.snp.bottom).offset(42)
            $0.size.equalTo(134)
        }
        
        nextButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupActions() {
        //TODO: ProfileView action 받아서 처리
        nextButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
    }
    
    @objc private func nextBtnTapped() {
        coordinator?.showInvite()
    }
}
