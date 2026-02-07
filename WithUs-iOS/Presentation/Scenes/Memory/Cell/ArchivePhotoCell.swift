//
//  ArchivePhotoCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import UIKit
import SnapKit
import Then

class DateLabelView: UIView {
    let label = UILabel().then {
        $0.font = UIFont.pretendard12SemiBold
        $0.textColor = UIColor.gray900
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(label)
        
        label.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(6)
            $0.horizontalEdges.equalToSuperview().inset(4)
        }
    }
}

class ArchivePhotoCell: UICollectionViewCell {
    static let reuseId = "ArchivePhotoCell"
    
    private let dateLabel = DateLabelView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    
    private let combinedImageView = ArchiveRecentImageView()
    private let singleImageView = ArchiveBlurredImageView()
    
    private let checkboxImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(combinedImageView)
        contentView.addSubview(singleImageView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(checkboxImageView)
        
        combinedImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        singleImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalToSuperview().offset(8)
        }
        
        checkboxImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.trailing.equalToSuperview().offset(-6)
            $0.size.equalTo(18)
        }
    }
    
    func configure(
        photo: ArchivePhotoViewModel,
        showDate: Bool,
        dateText: String,
        isSelectionMode: Bool,
        isSelected: Bool
    ) {
        dateLabel.isHidden = !showDate
        dateLabel.label.text = dateText
        
        combinedImageView.isHidden = true
        singleImageView.isHidden = true
        
        switch photo.kind {
        case .combined:
            combinedImageView.isHidden = false
            combinedImageView.configure(
                topImageURL: photo.myImageUrl ?? "",
                bottomImageURL: photo.partnerImageUrl ?? ""
            )
            
        case .single:
            singleImageView.isHidden = false
            let imageUrl = photo.myImageUrl ?? photo.partnerImageUrl
            singleImageView.configure(backgroundImageURL: imageUrl ?? "")
        }
        
        checkboxImageView.isHidden = !isSelectionMode
        
        if isSelectionMode {
            if isSelected {
                checkboxImageView.image = UIImage(named: "ic_archive_checked")
            } else {
                checkboxImageView.image = UIImage(named: "ic_archive_no_checked")
            }
        }
    }
}
