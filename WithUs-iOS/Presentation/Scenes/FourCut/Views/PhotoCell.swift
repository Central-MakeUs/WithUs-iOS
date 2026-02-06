//
//  PhotoCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation
import UIKit
import Then
import SnapKit
import Photos

class PhotoCell: UICollectionViewCell {
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let checkmarkView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 9
        $0.isHidden = true
    }
    
    private let checkmarkLabel = UILabel().then {
        $0.textColor = .black
        $0.font = UIFont.pretendard12SemiBold
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(checkmarkView)
        checkmarkView.addSubview(checkmarkLabel)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        checkmarkView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.trailing.equalToSuperview().inset(6)
            make.width.height.equalTo(18)
        }
        
        checkmarkLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(with asset: PHAsset, isSelected: Bool, imageManager: PHCachingImageManager) {
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)

        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFill,
                                  options: nil) { [weak self] image, _ in
            self?.imageView.image = image
        }
        checkmarkView.isHidden = !isSelected
    }
    
    func setSelectionNumber(_ number: Int) {
        checkmarkLabel.text = "\(number)"
    }
}
