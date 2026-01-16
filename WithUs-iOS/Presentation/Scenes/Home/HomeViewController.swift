//
//  HomeViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

final class HomeViewController: BaseViewController {
    var coordinator: HomeCoordinator?
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "기록을 남기기 위한\n마지막 설정이 남아있어요"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "랜덤 질문 알림 시간과\n키워드 설정을 완료해주세요."
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
    }
    
    private let setupButton = UIButton().then {
        $0.setTitle("설정하러 가기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    override func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(imageView)
        view.addSubview(subTitleLabel)
        view.addSubview(setupButton)
        print("✅ [HomeVC] setupUI 완료, coordinator: \(coordinator != nil ? "있음" : "nil")")
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        setupButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
        print("✅ [HomeVC] setupConstraints 완료")
    }
    
    override func setupActions() {
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
        print("✅ [HomeVC] setupActions 완료, coordinator: \(coordinator != nil ? "있음" : "nil")")
        
        // 추가 확인
        if coordinator != nil {
            print("✅ [HomeVC] Coordinator 정상 연결: \(type(of: coordinator!))")
        }
    }
    
    @objc private func setupButtonTapped() {
        print("\n🔥🔥🔥 [HomeVC] 버튼 클릭됨! 🔥🔥🔥")
        print("🔥 coordinator 상태: \(coordinator != nil ? "있음" : "❌ NIL")")
        
        if let coord = coordinator {
            print("✅ coordinator 타입: \(type(of: coord))")
            print("✅ coordinator.navigationController: \(coord.navigationController)")
            print("✅ showKeywordSetting() 호출 시작")
            coord.showKeywordSetting()
        } else {
            print("❌❌❌ coordinator가 nil입니다! ❌❌❌")
        }
    }
}

