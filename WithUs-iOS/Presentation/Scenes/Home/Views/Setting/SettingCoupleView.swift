//
//  SettingCoupleView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import UIKit
import SnapKit
import Then

final class SettingCoupleView: UIView {
    
    var onTap: (() -> Void)?
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "기록을 남기기 위한\n마지막 설정이 남아있어요"
    }

    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "랜덤 질문 알림 시간과\n키워드 설정을 완료해주세요."
    }

    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemPink
    }

    private let setupButton = UIButton().then {
        $0.setTitle("설정하러 가기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        addSubview(imageView)
        addSubview(setupButton)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(108)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        setupButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
    }
    
    private func setupActions() {
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
    }
    
    @objc private func setupButtonTapped() {
        onTap?()
    }
}
