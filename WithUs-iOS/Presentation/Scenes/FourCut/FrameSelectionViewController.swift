//
//  FrameSelectionViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit

class FrameSelectionViewController: BaseViewController {
    
    weak var coordinator: FourCutCoordinator?
    
    private let titleLabel = UILabel().then {
        $0.text = "프레임을 선택해 주세요"
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
        $0.textAlignment = .center
    }
    
    // 프레임 컨테이너 (검은 배경)
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .black
    }
    
    // 상단 바
    private let topBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 6
    }
    
    // 하단 바
    private let bottomBar = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let withusLabel = UILabel().then {
        $0.text = "WITHUS"
        $0.font = UIFont.pretendard10Regular
        $0.textColor = .white
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 18
    }
    
    private let gridLayoutButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_grid_frame"), for: .normal)
        $0.tintColor = .black
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.black.cgColor
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor.gray100
    }
    
    private let verticalLayoutButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_vertical_frame"), for: .normal)
        $0.tintColor = .black
        $0.layer.cornerRadius = 12
        $0.backgroundColor = UIColor.gray100
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGridWithStackView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupActions() {
        
    }
    
    override func setNavigation() {
        setRightBarButton(
            image: UIImage(systemName: "checkmark"),
            action: #selector(checkButtonTapped),
            tintColor: .black
        )
        self.navigationItem.title = "1/4"
        setLeftBarButton(image: UIImage(systemName: "xmark"))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(titleLabel)
        view.addSubview(frameContainerView)
        view.addSubview(buttonStackView)
        
        frameContainerView.addSubview(topBar)
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(withusLabel)
        
        buttonStackView.addArrangedSubview(gridLayoutButton)
        buttonStackView.addArrangedSubview(verticalLayoutButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(54)
        }
        
        gridLayoutButton.snp.makeConstraints {
            $0.size.equalTo(54)
        }
        
        verticalLayoutButton.snp.makeConstraints {
            $0.size.equalTo(54)
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(buttonStackView.snp.top).offset(-53)
        }
        
        
        topBar.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(46)
        }
        
        bottomBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalTo(topBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.bottom.equalTo(bottomBar.snp.top)
        }
        
        withusLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setupGridWithStackView() {
        
        for row in 0..<2 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 6
            
            for col in 0..<2 {
                let index = row * 2 + col
                
                let imageView = UIImageView().then {
                    $0.backgroundColor = .lightGray   // 테스트용
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                    $0.layer.borderWidth = index == 0 ? 2 : 1
                    $0.layer.borderColor = index == 0
                    ? UIColor.systemBlue.cgColor
                    : UIColor.black.cgColor
                }
                
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    @objc private func checkButtonTapped() {
        let photoSelectionVC = PhotoSelectionViewController()
        navigationController?.pushViewController(photoSelectionVC, animated: true)
    }
}
