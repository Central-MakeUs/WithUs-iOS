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
        backgroundColor = .white
        layer.cornerRadius = 20
        addShadow(
            color: .black,
            opacity: 0.08,
            offset: CGSize(width: 4, height: 4),
            radius: 29
        )
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        clockImageView.snp.makeConstraints {
            $0.size.equalTo(161)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().priority(.low)
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(14)
        }
    }
    
    func configure(remainingTime: String) {
        titleLabel.text = remainingTime
    }
}
