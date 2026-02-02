//
//  ArchiveRecentImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation
import UIKit
import SnapKit
import Then
import Kingfisher

final class ArchiveRecentImageView: UIView {
    private let topCard = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let topImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
    }
   
    private let bottomCard = UIView().then {
        $0.clipsToBounds = true
    }
    
    private let bottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .gray200
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
        
        addSubview(bottomCard)
        bottomCard.addSubview(bottomImageView)
    }
    
    private func setupConstraints() {
        topCard.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(snp.centerY)
        }
        
        topImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomCard.snp.makeConstraints {
            $0.top.equalTo(snp.centerY)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(
        topImageURL: String,
        bottomImageURL: String,
    ) {
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
    }
}
