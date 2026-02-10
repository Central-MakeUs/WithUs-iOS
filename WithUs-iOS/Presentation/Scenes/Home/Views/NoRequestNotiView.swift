//
//  NoRequestNotiView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation
import UIKit
import Then
import SnapKit

final class NoRequestNotiView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "알림을 허용해주세요."
        $0.font = UIFont.pretendard24Bold
        $0.textColor = .gray900
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "inviteCodeSetting")
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "알림을 허용하고\n 상대방의 소식을 실시간으로 받아보세요."
        $0.font = UIFont.pretendard16Regular
        $0.textColor = .gray700
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
    }
    
    private let notificationButton = UIButton(configuration: .plain()).then {
        var config = UIButton.Configuration.plain()
        var titleAttr = AttributedString("알림 설정하기 →")
        titleAttr.font = UIFont.pretendard16SemiBold
        config.attributedTitle = titleAttr
        config.baseForegroundColor = .white
        config.background.backgroundColor = UIColor.gray900
        config.background.cornerRadius = 8
        
        $0.configuration = config
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(stackView)
        addSubview(notificationButton)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(subTitleLabel)
        
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(160)
        }
        
        notificationButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(38)
            $0.size.equalTo(CGSize(width: 167, height: 48))
            $0.centerX.equalToSuperview()
        }
    }
}
