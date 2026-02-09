//
//  CombinedImageCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/29/26.
//

import Foundation
import UIKit
import Then
import SnapKit

final class CombinedImageCell: UICollectionViewCell {
    static let reuseId = "CombinedImageCell"
    
    private let combinedView = CombinedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(combinedView)
        combinedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with data: DetailCellData) {
        combinedView
            .configure(
                topImageURL: data.myImageUrl ?? "",
                topName: data.myName ?? "",
                topTime: data.myTime ?? "",
                topProfileURL: data.myProfileUrl ?? "",
                bottomImageURL: data.partnerImageUrl ?? "",
                bottomName: data.partnerName ?? "",
                bottomTime: data.partnerTime ?? "",
                bottomProfileURL: data.partnerProfileUrl ?? ""
            )
    }
    
    func getCombinedImage() -> UIImage? {
        let renderer = UIGraphicsImageRenderer(bounds: combinedView.bounds)
        
        return renderer.image { context in
            combinedView.layer.render(in: context.cgContext)
        }
    }
}
