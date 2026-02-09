//
//  EmptyArchiveView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation
import UIKit
import SnapKit
import Then

final class EmptyArchiveView: UIView {
    private let emptyLabel = UILabel().then {
        $0.text = "저장된 사진이 없어요"
        $0.textColor = UIColor.gray900
        $0.font = UIFont.pretendard24Bold
    }
    
    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(named: "empty_archive")
        $0.contentMode = .scaleAspectFit
    }
    
    private let subLabel = UILabel().then {
        $0.text = "연인과 사진을 공유하면\n이곳에 차곡차곡 저장돼요."
        $0.textColor = UIColor.gray700
        $0.font = UIFont.pretendard16Regular
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        addSubview(stackView)
        
        stackView.addArrangedSubview(emptyLabel)
        stackView.addArrangedSubview(emptyImageView)
        stackView.addArrangedSubview(subLabel)
        
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(160)
        }
    }
}

