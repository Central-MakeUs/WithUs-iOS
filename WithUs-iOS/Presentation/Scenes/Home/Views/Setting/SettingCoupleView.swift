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
    
    private let topLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard20SemiBold
        $0.textColor = UIColor.gray900
        $0.text = "사진을 공유할 키워드를 등록하고\n일상을 특별하게 기록해보세요"
    }

    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "키워드 설정"
    }

    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemPink
    }

    private let setupButton = UIButton().then {
        $0.setTitle("키워드 등록하기", for: .normal)
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
        backgroundColor = .white
        layer.cornerRadius = 20
        addShadow(
             color: .black,
             opacity: 0.08,
             offset: CGSize(width: 4, height: 4),
             radius: 29
        )
        
        addSubview(topLabelStackView)
        addSubview(imageView)
        addSubview(setupButton)
        
        topLabelStackView.addArrangedSubview(subTitleLabel)
        topLabelStackView.addArrangedSubview(titleLabel)
    }

    private func setupConstraints() {
        topLabelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(161)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().priority(.low)
            $0.top.greaterThanOrEqualTo(topLabelStackView.snp.bottom).offset(14)
            $0.bottom.lessThanOrEqualTo(setupButton.snp.top).offset(-50)
        }
        
        setupButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-27)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
    }
    
    private func setupActions() {
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
    }
    
    @objc private func setupButtonTapped() {
        onTap?()
    }
}
