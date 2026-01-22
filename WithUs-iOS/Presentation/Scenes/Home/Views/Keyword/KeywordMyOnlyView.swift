//
//  KeywordMyOnlyView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class KeywordMyOnlyView: UIView {
    
    var onNotifyTapped: (() -> Void)?
    
    private let myImageCard = ImageCardView()
    
    private let placeholderView = UIView().then {
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 15
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "사진을 기다리고 있다고\n상대방에게 알림을 보내보세요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
    }
    
    private let notifyButton = UIButton().then {
        $0.setTitle("콕 찌르기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard14SemiBold
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
    
    private func setupUI() {
        addSubview(myImageCard)
        addSubview(placeholderView)
        addSubview(infoLabel)
        addSubview(notifyButton)
    }
    
    private func setupConstraints() {
        myImageCard.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(26)
            $0.height.equalTo(260)
        }
        
        placeholderView.snp.makeConstraints {
            $0.top.equalTo(myImageCard.snp.bottom).offset(38)
            $0.size.equalTo(80)
            $0.centerX.equalToSuperview()
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderView.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
        
        notifyButton.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(16)
            $0.size.equalTo(CGSize(width: 100, height: 41))
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setupActions() {
        notifyButton.addTarget(self, action: #selector(notifyButtonTapped), for: .touchUpInside)
    }
    
    @objc private func notifyButtonTapped() {
        onNotifyTapped?()
    }
    
    func configure(
        myImageURL: String,
        myName: String,
        myTime: String,
        myProfileURL: String
    ) {
        myImageCard.configure(
            imageURL: myImageURL,
            profileImageURL: myProfileURL, name: myName,
            time: myTime
        )
    }
}
