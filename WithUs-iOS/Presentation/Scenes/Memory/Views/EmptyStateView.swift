//
//  EmptyStateView.swift
//  WithUs-iOS
//

import UIKit
import SnapKit
import Then

final class EmptyDetailCell: UICollectionViewCell {
    static let reuseId = "EmptyDetailCell"
    
    private let emptyMainLabel = UILabel().then {
        $0.text = "저장된 사진이 없어요"
        $0.textColor = UIColor.gray900
        $0.font = UIFont.pretendard24Bold
    }
    
    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(named: "empty_archive")
        $0.contentMode = .scaleAspectFit
    }
    
    private let emptySubLabel = UILabel().then {
        $0.text = "주고 받은 사진이 삭제되어서\n확인이 불가능해요."
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
    private let emptyStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
        $0.alignment = .center
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
        contentView.addSubview(emptyStackView)
        
        emptyStackView.addArrangedSubview(emptyMainLabel)
        emptyStackView.addArrangedSubview(emptyImageView)
        emptyStackView.addArrangedSubview(emptySubLabel)
    }
    
    private func setupConstraints() {
        emptyImageView.snp.makeConstraints {
            $0.size.equalTo(160)
        }
        
        emptyStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
