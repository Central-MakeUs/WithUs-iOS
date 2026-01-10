//
//  LoginViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit
import Then

final class LoginViewController: BaseViewController {
    
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
        $0.isEnabled = false
    }
    
    private let appleButton = UIButton().then {
        $0.setTitle("Apple로 시작하기", for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
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
}
//
//import SwiftUI
//
//#if DEBUG
//struct LoginViewController_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginViewController()
//            .toPreview()
//    }
//}
//#endif
