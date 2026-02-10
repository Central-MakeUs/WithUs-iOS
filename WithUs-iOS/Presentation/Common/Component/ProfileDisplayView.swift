//
//  ProfileDisplayView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import UIKit
import SnapKit
import Kingfisher

class ProfileDisplayView: UIView {
    
    private let backgroundCircleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.clipsToBounds = true
    }
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let emptyProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "empty_profile")
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(backgroundCircleView)
        addSubview(profileImageView)
        addSubview(emptyProfileImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundCircleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundCircleView)
        }
        
        emptyProfileImageView.snp.makeConstraints { make in
            make.center.equalTo(backgroundCircleView)
            make.width.height.equalTo(backgroundCircleView).dividedBy(2)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundCircleView.layer.cornerRadius = backgroundCircleView.frame.width / 2
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
    
    func setProfileImage(_ url: String?) {
        if let profileUrl = url,
           let profile = URL(string: profileUrl) {
            emptyProfileImageView.isHidden = true
            profileImageView.isHidden = false
            profileImageView.kf.setImage(
                with: profile,
                placeholder: nil,
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            emptyProfileImageView.isHidden = false
            profileImageView.isHidden = true
        }
    }
}
