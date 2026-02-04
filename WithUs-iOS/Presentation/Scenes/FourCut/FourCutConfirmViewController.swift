//
//  FourCutConfirmViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/4/26.
//

import Foundation
import UIKit
import SnapKit
import Then

final class FourCutConfirmViewController: BaseViewController {
    weak var coordinator: FourCutCoordinator?
    var fourcut: UIImage?
    private let titleLabel = UILabel().then {
        $0.text = "커플 네컷이 완성됐어요!"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }
    
    private let fourcutImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
    }
    
    private let saveBtn = UIButton().then {
        $0.setTitle("갤러리에 저장하기", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.backgroundColor = UIColor.gray50
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let listBtn = UIButton().then {
        $0.setTitle("목록으로 가기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayPhotos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleLabel)
        view.addSubview(fourcutImageView)
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(saveBtn)
        buttonStackView.addArrangedSubview(listBtn)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(68)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
        }
        
        saveBtn.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        listBtn.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        fourcutImageView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(38)
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-27)
        }
    }
    
    private func displayPhotos() {
        guard let fourcut else { return }
        fourcutImageView.image = fourcut
    }
}
