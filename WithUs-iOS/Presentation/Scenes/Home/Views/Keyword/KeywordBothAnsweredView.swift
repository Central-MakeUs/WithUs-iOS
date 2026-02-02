//
//  KeywordBothAnsweredView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class KeywordBothAnsweredView: UIView {
    
    private let combinedImageView = CombinedImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .white
        addSubview(combinedImageView)
    }
    
    private func setupConstraints() {
        combinedImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(
        myImageURL: String,
        myName: String,
        myTime: String,
        myProfile: String,
        partnerImageURL: String,
        partnerName: String,
        partnerTime: String,
        parterProfile: String
    ) {
        combinedImageView
            .configure(
                topImageURL: myImageURL,
                topName: myName,
                topTime: myTime,
                topProfileURL: myProfile,
                bottomImageURL: partnerImageURL,
                bottomName: partnerName,
                bottomTime: partnerTime,
                bottomProfileURL: parterProfile
            )
    }
}
