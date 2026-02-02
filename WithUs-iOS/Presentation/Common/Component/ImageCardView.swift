//
//  ImageCardView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ImageCardView: UIView {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.pretendard10Regular
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(imageView)
        imageView.addSubview(profileImageView)
        imageView.addSubview(infoStackView)
        
        infoStackView.addArrangedSubview(nameLabel)
        infoStackView.addArrangedSubview(timeLabel)
    }
    
    private func setupConstraints() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(34)
        }
        
        infoStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func configure(
        imageURL: String,
        profileImageURL: String? = nil,
        name: String,
        time: String
    ) {
        nameLabel.text = name
        timeLabel.text = time
        
        if let url = URL(string: imageURL) {
            imageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
        
        if let profileImageURL, let profileURL = URL(string: profileImageURL) {
            profileImageView.kf
                .setImage(with: profileURL, placeholder: nil, options: [.transition(.fade(0.2)), .cacheOriginalImage])
        }
    }
}
