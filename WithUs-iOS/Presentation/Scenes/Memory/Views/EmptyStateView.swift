//
//  EmptyStateView.swift
//  WithUs-iOS
//

import UIKit
import SnapKit
import Then

final class EmptyDetailCell: UICollectionViewCell {
    static let reuseId = "EmptyDetailCell"
    
    private let emptyImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_empty_archive")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .black
    }
    
    private let emptyLabel = UILabel().then {
        $0.text = "삭제되었습니다."
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
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
        contentView.backgroundColor = UIColor.gray50
        contentView.addSubview(emptyImageView)
        contentView.addSubview(emptyLabel)
    }
    
    private func setupConstraints() {
        emptyImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.size.equalTo(80)
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
}
