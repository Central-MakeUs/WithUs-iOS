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
        $0.backgroundColor = UIColor.gray50
        $0.layer.cornerRadius = 67
        $0.clipsToBounds = true
    }
    
    let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.clipsToBounds = true
        $0.image = UIImage(systemName: "person.fill")
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
        addSubview(cameraButton)
        
        setupConstraints()
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        backgroundCircleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(134)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.center.equalTo(backgroundCircleView)
            make.width.height.equalTo(80)
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
    }
    
    @objc private func cameraButtonTapped() {
        delegate?.setProfileTapped()
    }
    
    func setProfileImage(_ image: UIImage?) {
        profileImageView.image = image
    }
}
