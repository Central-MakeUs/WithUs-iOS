//
//  BlurredImageCardView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class BlurredImageCardView: UIView {
    
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.pretendard(.semiBold, size: 12)
        $0.textColor = .white
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
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
        addSubview(backgroundImageView)
        addSubview(blurEffectView)
        addSubview(profileImageView)
        addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(timeLabel)
    }
    
    private func setupConstraints() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(20)
        }
        
        infoStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func configure(
        backgroundImage: UIImage?,
        profileImage: UIImage? = nil,
        name: String,
        time: String
    ) {
        backgroundImageView.image = backgroundImage
        profileImageView.image = profileImage
        nameLabel.text = name
        timeLabel.text = time
    }
    
    func configure(
        backgroundImageURL: String,
        profileImageURL: String? = nil,
        name: String,
        time: String
    ) {
        nameLabel.text = name
        timeLabel.text = time
        
        // TODO: Kingfisher 등으로 이미지 로드
        // backgroundImageView.kf.setImage(with: URL(string: backgroundImageURL))
        // if let profileURL = profileImageURL {
        //     profileImageView.kf.setImage(with: URL(string: profileURL))
        // }
    }
    
    /// 블러 효과 스타일 변경
    func setBlurStyle(_ style: UIBlurEffect.Style) {
        blurEffectView.effect = UIBlurEffect(style: style)
    }
}
