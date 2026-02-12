//
//  ProfileImageView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import SnapKit

protocol ProfileViewDelegate: AnyObject {
    func setProfileTapped()
}

class ProfileImageView: UIView {
    
    weak var delegate: ProfileViewDelegate?
    
    private let backgroundCircleView = UIView().then {
        $0.backgroundColor = .gray400
        $0.clipsToBounds = true
    }
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let emptyProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "empty_profile")
        $0.contentMode = .scaleAspectFit
    }
    
    let cameraButton = UIButton().then {
        $0.backgroundColor = UIColor.gray200
        $0.imageView?.contentMode = .scaleAspectFit
        let cameraIcon = UIImage(named : "ic_camera")
        $0.setImage(cameraIcon, for: .normal)
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
        addSubview(cameraButton)
        
        setupConstraints()
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
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
        
        cameraButton.snp.makeConstraints { make in
            make.right.equalTo(backgroundCircleView.snp.right).offset(0)
            make.bottom.equalTo(backgroundCircleView.snp.bottom).offset(0)
            make.width.height.equalTo(30)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        cameraButton.layer.cornerRadius = cameraButton.frame.width / 2
        backgroundCircleView.layer.cornerRadius = backgroundCircleView.frame.width / 2
    }
    
    @objc private func cameraButtonTapped() {
        delegate?.setProfileTapped()
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

    
    func hideCameraButton() {
        cameraButton.isHidden = true
    }
}
