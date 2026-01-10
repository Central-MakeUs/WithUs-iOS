//
//  PinDigitView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit
import Then

final class PinDigitView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "0"
        $0.backgroundColor = .white
        $0.textColor = UIColor.gray300
        $0.font = UIFont.pretendard24Bold
    }
    
    private let underlineView = UIView().then {
        $0.backgroundColor = UIColor.gray300
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(underlineView)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(snp.centerY).offset(-8)
        }
        
        underlineView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 20, height: 2))
        }
    }
    
    func configure(isFilled: Bool, digit: String? = nil) {
        UIView.animate(withDuration: 0.2) {
            if isFilled, let digit = digit {
                self.titleLabel.text = digit
                self.titleLabel.textColor = UIColor.gray900
                self.underlineView.backgroundColor = UIColor.gray900
            } else {
                self.titleLabel.text = "0"
                self.titleLabel.textColor = UIColor.gray300
                self.underlineView.backgroundColor = UIColor.gray300
            }
        }
    }
}
