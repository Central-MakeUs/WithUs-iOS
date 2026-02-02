//
//  BlurredDetailCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/29/26.
//

import Foundation
import UIKit
import Then
import SnapKit


final class BlurredDetailCell: UICollectionViewCell {
    static let reuseId = "BlurredDetailCell"
    
    private let blurredView = ArchiveBlurredImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(blurredView)
        blurredView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(imageURL: String) {
        blurredView.configure(backgroundImageURL: imageURL)
    }
}
