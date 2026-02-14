//
//  WaitingBothView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class WaitingBothView: UIView {
    
    var onSendPhotoTapped: (() -> Void)?
    
    private let topLabelStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 12
    }
    
    private let questionNumberLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "오늘의 일상"
    }
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard20SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let heartImageView = UIImageView().then {
        $0.image = UIImage(named: "waitingBoth")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemPink
        $0.layer.cornerRadius = 20
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "먼저 오늘의 질문에 답해보세요."
    }
    
    private let sendButton = UIButton().then {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
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
        
        addSubview(topLabelStackView)
        addSubview(heartImageView)
        addSubview(subTitleLabel)
        addSubview(sendButton)
        
        topLabelStackView.addArrangedSubview(questionNumberLabel)
        topLabelStackView.addArrangedSubview(questionLabel)
    }
    
    private func setupConstraints() {
        topLabelStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(56)
            $0.horizontalEdges.equalToSuperview().inset(30)
        }
        
        heartImageView.snp.makeConstraints {
            $0.size.equalTo(161)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().priority(.low)
            $0.top.greaterThanOrEqualTo(topLabelStackView.snp.bottom).offset(14)
            $0.bottom.lessThanOrEqualTo(subTitleLabel.snp.top).offset(-50)
        }
        
        
        subTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-27)
        }
        
        sendButton.snp.makeConstraints {
            $0.bottom.equalTo(subTitleLabel.snp.top).offset(-16)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sendButtonTapped() {
        onSendPhotoTapped?()
    }
    
    func configure(question: String, number: Int?, isTodayQuestion: Bool = true) {
        questionLabel.text = question
        if let number {
            questionNumberLabel.text = "#\(number)"
        }
        subTitleLabel.text = isTodayQuestion ? "먼저 오늘의 질문에 답해보세요." : "먼저 오늘의 일상 사진을 보내보세요."
    }
}
