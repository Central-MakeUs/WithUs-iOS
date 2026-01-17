//
//  QuestionPartnerOnlyView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class QuestionPartnerOnlyView: UIView {
    
    var onAnswerTapped: (() -> Void)?
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Regular
        $0.textColor = UIColor.gray900
    }
    
    private let partnerImageView = BlurredImageCardView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 3
        $0.text = "상대방이 어떤 사진을 보냈을까요?\n내 사진을 공유하면\n상대방의 사진도 확인할 수 있어요."
    }
    
    private let answerButton = UIButton().then {
        $0.setTitle("나도 전송하기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 16)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        addSubview(questionLabel)
        addSubview(partnerImageView)
        addSubview(subTitleLabel)
        addSubview(answerButton)
    }
    
    private func setupConstraints() {
        questionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(38)
            $0.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        partnerImageView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(partnerImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        answerButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
    }
    
    
    private func setupActions() {
        answerButton.addTarget(self, action: #selector(answerButtonTapped), for: .touchUpInside)
    }
    
    @objc private func answerButtonTapped() {
        onAnswerTapped?()
    }
    
    func configure(
        question: String,
        subTitle: String,
        partnerName: String,
        partnerImageURL: String,
        partmerTime: String
    ) {
        questionLabel.text = "Q.\n\(question)"
        subTitleLabel.text = subTitle
        partnerImageView
            .configure(backgroundImageURL: "", profileImageURL: partnerImageURL, name: partnerName, time: partmerTime)
    }
}
