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
    
    private let topCard = UIView().then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let myImageCard = ImageCardView()
    
    private let bottomCard = UIView()
    
    private let bottomStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 20
        $0.alignment = .center
    }
    
    private let infoLabel = UILabel().then {
        $0.text = "사진을 기다리고 있다고\n상대방에게 알림을 보내보세요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray700
    }
    
    private let notifyButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "콕 찌르기"
        config.image = UIImage(named: "ic_hand_finger")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
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
        addSubview(topCard)
        addSubview(bottomCard)
        topCard.addSubview(myImageCard)
        
        bottomCard.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(infoLabel)
        bottomStackView.addArrangedSubview(notifyButton)
    }
    
    private func setupConstraints() {
        topCard.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(snp.centerY)
        }
        
        myImageCard.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomCard.snp.makeConstraints {
            $0.top.equalTo(snp.centerY)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        notifyButton.snp.makeConstraints {
            $0.height.equalTo(48)
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
