//
//  CombinedImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

//MARK: -- ImageView의 특성은 .scaleAspectFill이다 -> image가 1대1로 들어오면 가로에 맞추고 위아래가 잘린다.
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
   
    private let topProfileCircle = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
    
    private let topNameLabel = UILabel().then {
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }
    
    private let topTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
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
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }
    
    private let bottomTimeLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
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
        // 상대방 카드
        addSubview(topCard)
        topCard.addSubview(topImageView)
        
        topImageView.addSubview(topProfileCircle)
        topImageView.addSubview(topInfoStackView)
        
        topInfoStackView.addArrangedSubview(topNameLabel)
        topInfoStackView.addArrangedSubview(topTimeLabel)
        
        // 내 카드
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
            $0.bottom.equalTo(snp.centerY) // 딱 붙음 (간격 없음)
        }
        
        topImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topProfileCircle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(20)
        }
        
        topInfoStackView.snp.makeConstraints {
            $0.centerY.equalTo(topProfileCircle)
            $0.leading.equalTo(topProfileCircle.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        // 내 카드 (아래쪽 절반)
        bottomCard.snp.makeConstraints {
            $0.top.equalTo(snp.centerY) // 딱 붙음 (간격 없음)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomProfileCircle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(20)
        }
        
        bottomInfoStackView.snp.makeConstraints {
            $0.centerY.equalTo(bottomProfileCircle)
            $0.leading.equalTo(bottomProfileCircle.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
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
        
        bottomImageView.image = bottomImage
        bottomNameLabel.text = bottomName
        bottomTimeLabel.text = bottomTime
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
        
        bottomNameLabel.text = bottomName
        bottomTimeLabel.text = bottomTime
        
        // TODO: URLSession으로 이미지 로드
        print("🔵 [CombinedImageView] 이미지 로드")
        print("  - Top: \(topImageURL)")
        print("  - Bottom: \(bottomImageURL)")
        
        if let topUrl = URL(string: topImageURL),
           let bottomUrl = URL(string: bottomImageURL) {
            loadImage(from: topUrl, completion: { [weak self] image in
                self?.topImageView.image = image
            })
            
            loadImage(from: bottomUrl, completion: { [weak self] image in
                self?.bottomImageView.image = image
            })
        }
    }
    
    private func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
