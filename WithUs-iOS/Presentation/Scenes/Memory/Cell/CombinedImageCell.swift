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
    
    func configure(with data: SinglePhotoData) {
        // TODO: Adjust configure parameters if different from below
//        combinedView
//            .configure(
//                topImageURL: data.imageURL,
//                topName: data.name,
//                topTime: data.date,
//                topProfileURL: "",
//                bottomImageURL: data.imageURL,
//                bottomName: data.name,
//                bottomTime: data.date,
//                bottomProfileURL: ""
//            )
    }
}
