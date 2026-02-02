//
//  QuestionBothAnsweredView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class QuestionBothAnsweredView: UIView {
   
    private let questionLabel = UILabel().then {
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray700
        $0.textAlignment = .center
        $0.numberOfLines = 2
    }
    
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
        layer.cornerRadius = 20
        addShadow(
            color: .black,
            opacity: 0.08,
            offset: CGSize(width: 4, height: 4),
            radius: 29
        )
        
        addSubview(questionLabel)
        addSubview(combinedImageView)
    }
    
    private func setupConstraints() {
        questionLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        combinedImageView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(10)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func configure(
        question: String,
        myImageURL: String,
        myName: String,
        myTime: String,
        myProfile: String,
        partnerImageURL: String,
        partnerName: String,
        partnerTime: String,
        parterProfile: String
    ) {
        questionLabel.text = question
        
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
