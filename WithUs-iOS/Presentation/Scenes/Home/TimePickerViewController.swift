//
//  TimePickerViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

final class TimePickerViewController: BaseViewController {
    var coordinator: HomeCoordinator?
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "오늘의 랜덤 질문을\n받을 시간을 정해 주세요"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "하루 한 번, 우리의 추억을\n회고할 수 있는 랜덤 질문이 도착해요."
    }
    
    private let timePicker = UIDatePicker().then {
        $0.datePickerMode = .time
        $0.preferredDatePickerStyle = .wheels
        $0.locale = Locale(identifier: "en_US")
    }
    
    private let setupButton = UIButton().then {
        $0.setTitle("설정 완료하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    override func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(timePicker)
        view.addSubview(setupButton)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(54)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        timePicker.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(70)
            $0.size.equalTo(CGSize(width: 200, height: 180))
            $0.centerX.equalToSuperview()
        }
        
        setupButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(56)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setupActions() {
        timePicker.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
    }
    
    @objc private func timeChanged(_ sender: UIDatePicker) {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale(identifier: "en_US")
        
        let timeString = formatter.string(from: sender.date)
        print("선택된 시간: \(timeString)")
    }
    
    @objc private func setupButtonTapped() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // 24시간 형식
        let timeString = formatter.string(from: timePicker.date)
        
        print("설정 완료: \(timeString)")
        
        
        coordinator?.finishSetting(selectedTime: timeString)
    }
    
}

