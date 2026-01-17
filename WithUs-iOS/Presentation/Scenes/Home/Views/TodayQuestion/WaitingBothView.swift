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
    
    private let questionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Regular
        $0.textColor = UIColor.gray900
    }
    
    private let heartImageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemPink
        $0.layer.cornerRadius = 20
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "질문에 대한 나의 마음을\n사진으로 표현해주세요"
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
        addSubview(questionLabel)
        addSubview(heartImageView)
        addSubview(subTitleLabel)
        addSubview(sendButton)
    }
    
    private func setupConstraints() {
        questionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(38)
            $0.leading.trailing.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        heartImageView.snp.makeConstraints {
            $0.top.equalTo(questionLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(heartImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sendButtonTapped() {
        onSendPhotoTapped?()
    }
    
    func configure(question: String) {
        questionLabel.text = "Q.\n\(question)"
    }
}
