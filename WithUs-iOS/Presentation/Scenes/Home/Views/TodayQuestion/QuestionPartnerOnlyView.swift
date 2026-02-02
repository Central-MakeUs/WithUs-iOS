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
    
    private let topLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let questionNumberLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray300
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "#3."
    }
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard20SemiBold
        $0.textColor = UIColor.gray50
    }
    
    private let partnerImageView = BlurredImageCardView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let answerButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "사진 전송하기"
        config.image = UIImage(named: "ic_home_camera")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = UIColor.gray50
        config.background.backgroundColor = UIColor.gray900
        config.background.cornerRadius = 8
        $0.configuration = config
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard12Regular
        $0.textColor = UIColor.gray300
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.text = "내 사진을 공유하고 상대의 사진을 확인해보세요."
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
        layer.cornerRadius = 20
        addSubview(partnerImageView)
        partnerImageView.addSubview(topLabelStackView)
        partnerImageView.addSubview(answerButton)
        partnerImageView.addSubview(subTitleLabel)
        
        topLabelStackView.addArrangedSubview(questionNumberLabel)
        topLabelStackView.addArrangedSubview(questionLabel)
    }
    
    private func setupConstraints() {
        partnerImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topLabelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(136)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-27)
            $0.centerX.equalToSuperview()
        }
        
        answerButton.snp.makeConstraints {
            $0.bottom.equalTo(subTitleLabel.snp.top).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(52)
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
        name: String,
        profile: String,
        image: String,
        time: String
    ) {
        questionLabel.text = question
        partnerImageView
            .configure(
                backgroundImageURL: image,
                profileImageURL: profile,
                name: name,
                time: time
            )
    }
}
