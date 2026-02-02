//
//  ArchiveBlurredImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ArchiveBlurredImageView: UIView {
    private let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    private let mainImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let imageContainerView = UIView().then {
        $0.backgroundColor = .clear
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
        addSubview(imageContainerView)
        
        imageContainerView.addSubview(mainImageView)
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
    }
    
    func configure(backgroundImageURL: String) {
        if let url = URL(string: backgroundImageURL) {
            
            backgroundImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
            
            mainImageView.kf.setImage(
                with: url,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        }
    }
}
