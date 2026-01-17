//
//  KeywordParterOnlyView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class KeywordPartnerOnlyView: UIView {
    
    var onSendPhotoTapped: (() -> Void)?
    
    private let topPlaceholder = UIView().then {
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "jpg님이 쏘피님의 사진을\n기다리고 있어요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
    }
    
    private let sendButton = UIButton().then {
        $0.setTitle("전송하러 가기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard14SemiBold
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    private let partnerImageCard = ImageCardView()
    
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
        
        addSubview(topPlaceholder)
        addSubview(infoLabel)
        addSubview(sendButton)
        addSubview(partnerImageCard)
    }
    
    private func setupConstraints() {
        topPlaceholder.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(80)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(topPlaceholder.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        sendButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 125, height: 41))
        }
        
        partnerImageCard.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.height.equalTo(260)
        }
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    @objc private func sendButtonTapped() {
        onSendPhotoTapped?()
    }
    
    func configure(
        partnerImageURL: String,
        partnerName: String,
        partnerTime: String,
        partnerCaption: String,
        myName: String
    ) {
        partnerImageCard.configure(
            imageURL: partnerImageURL,
            name: partnerName,
            time: partnerTime,
            caption: partnerCaption
        )
        
        infoLabel.text = "\(partnerName)님이 \(myName)님의 사진을\n기다리고 있어요!"
    }
}
