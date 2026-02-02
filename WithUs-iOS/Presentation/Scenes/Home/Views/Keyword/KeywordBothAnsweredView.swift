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
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(
        myImageURL: String,
        myName: String,
        myTime: String,
        myCaption: String,
        partnerImageURL: String,
        partnerName: String,
        partnerTime: String,
        partnerCaption: String
    ) {
//        combinedImageView.configure(
//            topImageURL: partnerImageURL,
//            topName: partnerName,
//            topTime: partnerTime,
//            topCaption: partnerCaption,
//            bottomImageURL: myImageURL,
//            bottomName: myName,
//            bottomTime: myTime,
//            bottomCaption: myCaption
//        )
    }
}
