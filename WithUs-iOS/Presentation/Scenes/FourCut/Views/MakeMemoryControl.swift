//
//  MakeMemoryControl.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/5/26.
//

import Foundation
import UIKit
import SnapKit
import Then

final class MakeMemoryControl: UIControl {
    
    private let controlLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray50
        $0.text = "jpg님과 쏘피님이 함께한\n추억을 직접 만들어 보세요!"
        $0.numberOfLines = 2
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
        $0.image = UIImage(named: "ic_circle_arrow")
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        stackView.addArrangedSubview(controlLabel)
        stackView.addArrangedSubview(imageView)
        
        stackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.verticalEdges.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints {
            $0.size.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
    }
}
