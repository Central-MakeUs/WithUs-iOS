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
    private var requestID: PHImageRequestID?
    private var currentAsset: PHAsset?  // ✅ 현재 asset 추적
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        checkmarkView.isHidden = true
        checkmarkLabel.text = nil
        currentAsset = nil  // ✅ asset 초기화
        
        if let id = requestID {
            PHImageManager.default().cancelImageRequest(id)
            requestID = nil
        }
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
        imageView.image = nil
        currentAsset = asset  // ✅ 현재 asset 저장
        
        let scale = UIScreen.main.scale
        let itemWidth = (UIScreen.main.bounds.width - 4) / 3
        let targetSize = CGSize(width: itemWidth * scale, height: itemWidth * scale)
        
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic  // 저화질 먼저, 고화질 나중
        options.resizeMode = .exact            // ✅ fast → exact로 화질 개선
        options.isNetworkAccessAllowed = true
        
        requestID = imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { [weak self] image, _ in
            guard let self = self else { return }
            // ✅ 현재 셀의 asset과 같을 때만 이미지 세팅 (잔상 방지 핵심!)
            guard self.currentAsset == asset else { return }
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        
        checkmarkView.isHidden = !isSelected
    }
    
    func setSelectionNumber(_ number: Int) {
        checkmarkLabel.text = "\(number)"
    }
}
