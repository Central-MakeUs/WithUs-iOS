//
//  EmptyNotiView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation
import UIKit
import SnapKit
import Then

final class EmptyNotiView: UIView {
    private let titleLabel = UILabel().then {
        $0.text = "아직 도착한 알림이 없어요."
        $0.font = UIFont.pretendard24Bold
        $0.textColor = .gray900
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "empty_archive")
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "새로운 소식이 오면 바로 알려드릴게요."
        $0.font = UIFont.pretendard16Regular
        $0.textColor = .gray700
        $0.textAlignment = .center
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
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
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(subTitleLabel)
        
        stackView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(160)
        }
    }
}
