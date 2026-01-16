//
//  CombinedImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

// MARK: - CombinedImageView (두 이미지를 상하로 합침)
final class CombinedImageView: UIView {
    
    // 상대방 카드
    private let topCard = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // 위쪽만 둥글게
        $0.clipsToBounds = true
    }
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
    }
    
    private let topOverlay = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    private let topProfileCircle = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let topNameLabel = UILabel().then {
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }
    
    private let topTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
    }
    
    private let topCaptionLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white
    }
    
    // 내 카드
    private let bottomCard = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner] // 아래쪽만 둥글게
        $0.clipsToBounds = true
    }
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
    }
    
    private let bottomOverlay = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }
    
    private let bottomProfileCircle = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let bottomNameLabel = UILabel().then {
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }
    
    private let bottomTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
    }
    
    private let bottomCaptionLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
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
        // 상대방 카드
        addSubview(topCard)
        topCard.addSubview(topImageView)
        topCard.addSubview(topOverlay)
        topCard.addSubview(topProfileCircle)
        topCard.addSubview(topNameLabel)
        topCard.addSubview(topTimeLabel)
        topCard.addSubview(topCaptionLabel)
        
        // 내 카드
        addSubview(bottomCard)
        bottomCard.addSubview(bottomImageView)
        bottomCard.addSubview(bottomOverlay)
        bottomCard.addSubview(bottomProfileCircle)
        bottomCard.addSubview(bottomNameLabel)
        bottomCard.addSubview(bottomTimeLabel)
        bottomCard.addSubview(bottomCaptionLabel)
    }
    
    private func setupConstraints() {
        // 상대방 카드 (위쪽 절반)
        topCard.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(snp.centerY) // 딱 붙음 (간격 없음)
        }
        
        topImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topProfileCircle.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        topNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(topProfileCircle)
            $0.leading.equalTo(topProfileCircle.snp.trailing).offset(8)
        }
        
        topTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(topProfileCircle)
            $0.leading.equalTo(topNameLabel.snp.trailing).offset(4)
        }
        
        topCaptionLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(16)
        }
        
        // 내 카드 (아래쪽 절반)
        bottomCard.snp.makeConstraints {
            $0.top.equalTo(snp.centerY) // 딱 붙음 (간격 없음)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomProfileCircle.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }
        
        bottomNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(bottomProfileCircle)
            $0.leading.equalTo(bottomProfileCircle.snp.trailing).offset(8)
        }
        
        bottomTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(bottomProfileCircle)
            $0.leading.equalTo(bottomNameLabel.snp.trailing).offset(4)
        }
        
        bottomCaptionLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Public Methods
    func configure(
        topImage: UIImage?,
        topName: String,
        topTime: String,
        topCaption: String,
        bottomImage: UIImage?,
        bottomName: String,
        bottomTime: String,
        bottomCaption: String
    ) {
        topImageView.image = topImage
        topNameLabel.text = topName
        topTimeLabel.text = topTime
        topCaptionLabel.text = topCaption
        
        bottomImageView.image = bottomImage
        bottomNameLabel.text = bottomName
        bottomTimeLabel.text = bottomTime
        bottomCaptionLabel.text = bottomCaption
    }
    
    // URL로 이미지 로드 (옵션)
    func configure(
        topImageURL: String,
        topName: String,
        topTime: String,
        topCaption: String,
        bottomImageURL: String,
        bottomName: String,
        bottomTime: String,
        bottomCaption: String
    ) {
        topNameLabel.text = topName
        topTimeLabel.text = topTime
        topCaptionLabel.text = topCaption
        
        bottomNameLabel.text = bottomName
        bottomTimeLabel.text = bottomTime
        bottomCaptionLabel.text = bottomCaption
        
        // TODO: URLSession으로 이미지 로드
        print("🔵 [CombinedImageView] 이미지 로드")
        print("  - Top: \(topImageURL)")
        print("  - Bottom: \(bottomImageURL)")
    }
}
