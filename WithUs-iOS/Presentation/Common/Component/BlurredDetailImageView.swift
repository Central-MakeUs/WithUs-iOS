//
//  BlurredDetailImageView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import UIKit
import SnapKit
import Then

final class BlurredDetailImageView: UIView {
    
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 16
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let imageContainerView = UIView().then {
        $0.backgroundColor = .clear
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
    
    private func setupUI() {
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(backgroundImageView)
        addSubview(blurEffectView)
        addSubview(mainImageView)
        addSubview(imageContainerView)
        
        imageContainerView.addSubview(mainImageView)
        mainImageView.addSubview(profileImageView)
        mainImageView.addSubview(infoStackView)
        
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
        
        imageContainerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(imageContainerView.snp.width)
        }
        
        mainImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.leading.equalTo(imageContainerView).inset(16)
            $0.size.equalTo(34)
        }
        
        infoStackView.snp.makeConstraints {
            $0.centerY.equalTo(profileImageView)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
    }
    
    /// UIImage로 설정
    func configure(
        image: UIImage?,
        name: String,
        time: String,
        caption: String
    ) {
        // 배경 이미지 (블러)
        backgroundImageView.image = image
        
        // 메인 이미지 (선명)
        mainImageView.image = image
        
        // 텍스트 정보
        nameLabel.text = name
        timeLabel.text = time
    }
    
    func configure(
        imageURL: String,
        name: String,
        time: String,
    ) {
        nameLabel.text = name
        timeLabel.text = time
        
        // TODO: URLSession 또는 Kingfisher로 이미지 로드
        if let url = URL(string: imageURL) {
            // 임시: 테스트용 이미지 로드
            loadImage(from: url) { [weak self] image in
                self?.backgroundImageView.image = image
                self?.mainImageView.image = image
            }
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
