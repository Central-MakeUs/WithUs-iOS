//
//  ImageCardView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class ImageCardView: UIView {
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 16
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let overlayView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = .white
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 3
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
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(34)
        }
        
        infoStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func configure(
        image: UIImage?,
        profileImage: UIImage? = nil,
        name: String,
        time: String,
        caption: String
    ) {
        imageView.image = image
        profileImageView.image = profileImage
        nameLabel.text = name
        timeLabel.text = time
    }
    
    /// URL로 이미지 설정
    func configure(
        imageURL: String,
        profileImageURL: String? = nil,
        name: String,
        time: String,
        caption: String
    ) {
        nameLabel.text = name
        timeLabel.text = time
        
        // TODO: 이미지 로딩 라이브러리 사용
        // imageView.kf.setImage(with: URL(string: imageURL))
        // if let profileURL = profileImageURL {
        //     profileImageView.kf.setImage(with: URL(string: profileURL))
        // }
    }
}
