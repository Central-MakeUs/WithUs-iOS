//
//  CombinedImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

//MARK: -- ImageView의 특성은 .scaleAspectFill이다 -> image가 1대1로 들어오면 가로에 맞추고 위아래가 잘린다.
final class CombinedImageView: UIView {
    
    private let topCard = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        $0.clipsToBounds = true
    }
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
    }
   
    private let topProfileCircle = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
    }
    
    private let topNameLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    private let topTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard10Regular
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    private let topInfoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.alignment = .leading
    }
    
    private let bottomCard = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        $0.clipsToBounds = true
    }
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
    }
   
    private let bottomProfileCircle = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let bottomNameLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    private let bottomTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard10Regular
        $0.textColor = UIColor(hex: "#FFFFFF")
    }
    
    
    private let bottomInfoStackView = UIStackView().then {
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
    
    private func setupUI() {
        addSubview(topCard)
        topCard.addSubview(topImageView)
        
        topImageView.addSubview(topProfileCircle)
        topImageView.addSubview(topInfoStackView)
        
        topInfoStackView.addArrangedSubview(topNameLabel)
        topInfoStackView.addArrangedSubview(topTimeLabel)
        
        addSubview(bottomCard)
        bottomCard.addSubview(bottomImageView)
        
        bottomImageView.addSubview(bottomProfileCircle)
        bottomImageView.addSubview(bottomInfoStackView)
        
        bottomInfoStackView.addArrangedSubview(bottomNameLabel)
        bottomInfoStackView.addArrangedSubview(bottomTimeLabel)
    }
    
    private func setupConstraints() {
        topCard.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(snp.centerY)
        }
        
        topImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topProfileCircle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(34)
        }
        
        topInfoStackView.snp.makeConstraints {
            $0.centerY.equalTo(topProfileCircle)
            $0.leading.equalTo(topProfileCircle.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        bottomCard.snp.makeConstraints {
            $0.top.equalTo(snp.centerY)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomProfileCircle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(34)
        }
        
        bottomInfoStackView.snp.makeConstraints {
            $0.centerY.equalTo(bottomProfileCircle)
            $0.leading.equalTo(bottomProfileCircle.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    func configure(
        topImageURL: String,
        topName: String,
        topTime: String,
        topProfileURL: String,
        bottomImageURL: String,
        bottomName: String,
        bottomTime: String,
        bottomProfileURL: String
    ) {
        topNameLabel.text = topName
        topTimeLabel.text = topTime
        
        bottomNameLabel.text = bottomName
        bottomTimeLabel.text = bottomTime
        
        if let topUrl = URL(string: topImageURL),
           let bottomUrl = URL(string: bottomImageURL) {
            topImageView.kf.setImage(with: topUrl, placeholder: nil, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ])
            
            bottomImageView.kf.setImage(with: bottomUrl, placeholder: nil, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ])
        }
        
        if let topProfileUrl = URL(string: topProfileURL),
           let bottomProfileUrl = URL(string: bottomProfileURL) {
            topProfileCircle.kf.setImage(with: topProfileUrl, placeholder: nil, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ])
            
            bottomProfileCircle.kf.setImage(with: bottomProfileUrl, placeholder: nil, options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ])
        }
    }
}
