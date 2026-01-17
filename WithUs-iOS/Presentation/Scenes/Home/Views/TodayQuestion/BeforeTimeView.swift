//
//  BeforeTimeView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class BeforeTimeView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Regular
        $0.textColor = UIColor.gray900
    }
    
    private let clockImageView = UIImageView().then {
        $0.image = UIImage(systemName: "clock.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = UIColor.gray200
        $0.layer.cornerRadius = 20
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(clockImageView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        clockImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
    }
    
    func configure(remainingTime: String) {
        titleLabel.text = "오늘의 랜덤 질문이\n\(remainingTime) 후에 도착해요!"
    }
}
