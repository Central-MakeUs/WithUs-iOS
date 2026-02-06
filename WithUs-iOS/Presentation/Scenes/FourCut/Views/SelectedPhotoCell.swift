//
//  SelectedPhotoCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation
import UIKit
import SnapKit
import Then
import Photos

class SelectedPhotoCell: UICollectionViewCell {
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let removeButton = UIButton(type: .system).then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 9
        $0.clipsToBounds = true
        let config = UIImage.SymbolConfiguration(pointSize: 10.8, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
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
        contentView.addSubview(removeButton)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        removeButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.trailing.equalToSuperview().inset(4)
            make.width.height.equalTo(18)
        }
    }
    
    func configure(with asset: PHAsset, imageManager: PHCachingImageManager, index: Int) {
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: contentView.bounds.width * scale,
                                height: contentView.bounds.height * scale)
        let options = PHImageRequestOptions()
        options.resizeMode = .fast
        options.deliveryMode = .opportunistic
        imageManager.requestImage(for: asset,
                                  targetSize: targetSize,
                                  contentMode: .aspectFill,
                                  options: options) { [weak self] image, _ in
            self?.imageView.image = image
        }
    }
}

