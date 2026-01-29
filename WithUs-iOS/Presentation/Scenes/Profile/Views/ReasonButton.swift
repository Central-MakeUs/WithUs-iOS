//
//  ReasonButton.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import Foundation
import UIKit
import Then
import SnapKit

class ReasonButton: UIButton {
    
    private let radioImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_reason_no_checked")
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabelView = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.numberOfLines = 0
    }
    
    override var isSelected: Bool {
        didSet {
            updateUI()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabelView.text = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray200.cgColor
        
        addSubview(radioImageView)
        addSubview(titleLabelView)
        
        radioImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(18)
        }
        
        titleLabelView.snp.makeConstraints {
            $0.leading.equalTo(radioImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.height.equalTo(56)
        }
    }
    
    private func updateUI() {
        if isSelected {
            radioImageView.image = UIImage(named: "ic_reason_checked")
            layer.borderColor = UIColor.gray900.cgColor
            titleLabelView.textColor = UIColor.gray900
            layer.borderWidth = 2
        } else {
            radioImageView.image = UIImage(named: "ic_reason_no_checked")
            layer.borderColor = UIColor.gray200.cgColor
            titleLabelView.textColor = UIColor.gray500
            layer.borderWidth = 1
        }
    }
}
