//
//  SplashViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import Then
import SnapKit

final class SplashViewController: UIViewController {
    private let logoImageView = UIImageView().then {
        $0.image = UIImage(named: "splash_logo")
        $0.contentMode = .scaleAspectFit
    }
    
    private let logoTitleLabel = UILabel().then {
        $0.text = "사진으로 쌓이는 우리의 일상"
        $0.font = UIFont.pretendard20Regular
        $0.textColor = .white
    }
    
    private let logoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 4
        $0.distribution = .fill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(logoStackView)
        
        logoStackView.addArrangedSubview(logoImageView)
        logoStackView.addArrangedSubview(logoTitleLabel)
        
        logoStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 254, height: 67))
        }
    }
}
