//
//  HomeViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI

final class HomeViewController: BaseViewController {
    var coordinator: HomeCoordinator?
    
    private var isSettingCompleted: Bool = false
    private var keywords: [Keyword] = [
        Keyword(text: "오늘의 질문"),
        Keyword(text: "맛집"),
        Keyword(text: "여행"),
        Keyword(text: "데이트")
    ]
    private var selectedKeywordIndex: Int = 0
    private var currentQuestion: QuestionData?
    
    // MARK: - Container Views
    private let beforeSettingContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let afterSettingContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    // MARK: - Before Setting UI
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
        $0.tintColor = .systemPink
    }
    
    private let setupButton = UIButton().then {
        $0.setTitle("설정하러 가기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    // MARK: - After Setting UI (공통)
    private lazy var keywordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - 1. 시간 전
    private let beforeTimeView = UIView()
    
    private let beforeTimeLabel = UILabel().then {
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Regular
        $0.textColor = UIColor.gray900
    }
    
    private let beforeTimeImageView = UIImageView().then {
        $0.image = UIImage(systemName: "clock.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemGray3
    }
    
    // MARK: - 2. 둘 다 안보냄
    private let waitingBothView = UIView().then {
        $0.isHidden = true
    }
    
    private let waitingQuestionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
    }
    
    private let waitingImageView = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemPink
    }
    
    private let waitingSubLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "질문에 대한 나의 마음을\n사진으로 표현해주세요"
    }
    
    private let waitingButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "사진 전송하기"
        config.image = UIImage(named: "ic_home_camera")
        config.imagePlacement = .leading
        config.imagePadding = 6
        config.baseForegroundColor = UIColor.gray50
        config.background.backgroundColor = UIColor.gray900
        config.background.cornerRadius = 8
        $0.configuration = config
    }
    
    // MARK: - 3. 상대만 보냄
    private let partnerOnlyView = UIView().then {
        $0.isHidden = true
    }
    
    private let partnerQuestionLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
    }
    
    private let partnerImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light)).then {
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
    }
    
    private let partnerBadgeView = UIView()
    
    private let partnerProfileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let partnerNameLabel = UILabel().then {
        $0.text = "JPG"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }
    
    private let partnerTimeLabel = UILabel().then {
        $0.text = "1시간 전 완료"
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
    }
    
    private let partnerInfoLabel = UILabel().then {
        $0.text = "상대방이 먼저 사진을 보냈어요\n내 사진을 공개하면\n상대방의 사진도 확인할 수 있어요."
        $0.numberOfLines = 3
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
    }
    
    private let partnerButton = UIButton().then {
        $0.setTitle("나도 답변하기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 16)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    // MARK: - 4. 둘 다 보냄 (CombinedImageView 사용) ✅
    private let bothAnsweredView = UIView().then {
        $0.isHidden = true
    }
    
    private let combinedImageView = CombinedImageView()
    
    // MARK: - 1. 둘 다 보냄 (키워드) - CombinedImageView 재사용
    private let keywordBothView = UIView().then {
        $0.isHidden = true
    }

    private let keywordCombinedImageView = CombinedImageView()

    // MARK: - 2. 내가 보냄, 상대 안보냄
    private let keywordMyOnlyView = UIView().then {
        $0.isHidden = true
    }

    private let myOnlyTopImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }

    private let myOnlyOverlay = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }

    private let myOnlyProfileCircle = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }

    private let myOnlyNameLabel = UILabel().then {
        $0.text = "쏘피"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }

    private let myOnlyTimeLabel = UILabel().then {
        $0.text = "PM 12:30"
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
    }

    private let myOnlyCaptionLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white
    }

    private let myOnlyBottomPlaceholder = UIView().then {
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
    }

    private let myOnlyInfoLabel = UILabel().then {
        $0.text = "사진을 기다리고 있다고\n상대방에게 알림을 보내보세요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
    }

    private let myOnlyNotifyButton = UIButton().then {
        $0.setTitle("콕 찌르기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 16)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }

    // MARK: - 3. 상대 보냄, 내가 안보냄
    private let keywordPartnerOnlyView = UIView().then {
        $0.isHidden = true
    }

    private let partnerOnlyTopPlaceholder = UIView().then {
        $0.backgroundColor = .gray200
        $0.layer.cornerRadius = 12
    }

    private let partnerOnlyInfoLabel = UILabel().then {
        $0.text = "jpg님이 쏘피님의 사진을\n기다리고 있어요!"
        $0.numberOfLines = 2
        $0.textAlignment = .center
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray900
    }

    private let partnerOnlySendButton = UIButton().then {
        $0.setTitle("전송하러 가기 →", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 16)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }

    private let partnerOnlyBottomImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 12
        $0.clipsToBounds = true
        $0.backgroundColor = .gray200
    }

    private let partnerOnlyOverlay = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.3)
    }

    private let partnerOnlyProfileCircle = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }

    private let partnerOnlyNameLabel = UILabel().then {
        $0.text = "jpg"
        $0.font = UIFont.pretendard(.semiBold, size: 14)
        $0.textColor = .white
    }

    private let partnerOnlyTimeLabel = UILabel().then {
        $0.text = "PM 12:30"
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white.withAlphaComponent(0.8)
    }

    private let partnerOnlyCaptionLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 12)
        $0.textColor = .white
    }
    
    
    private var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, KeywordCellData> { cell, indexPath, item in
        cell.contentConfiguration = UIHostingConfiguration {
            KeywordCellView(
                keyword: item.keyword.text,
                isSelected: item.isSelected,
                isAddButton: item.keyword.isAddButton
            )
        }
        .margins(.all, 0)
        .background(Color.clear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMockQuestion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        isSettingCompleted = UserDefaults.standard.bool(forKey: "isSettingCompleted")
        switchContainer()
    }
    
    override func setupUI() {
        view.addSubview(beforeSettingContainerView)
        view.addSubview(afterSettingContainerView)
        
        // Before Setting
        beforeSettingContainerView.addSubview(titleLabel)
        beforeSettingContainerView.addSubview(imageView)
        beforeSettingContainerView.addSubview(subTitleLabel)
        beforeSettingContainerView.addSubview(setupButton)
        
        // After Setting - 공통
        afterSettingContainerView.addSubview(keywordCollectionView)
        
        // 1. 시간 전
        afterSettingContainerView.addSubview(beforeTimeView)
        beforeTimeView.addSubview(beforeTimeLabel)
        beforeTimeView.addSubview(beforeTimeImageView)
        
        // 2. 둘 다 안보냄
        afterSettingContainerView.addSubview(waitingBothView)
        waitingBothView.addSubview(waitingQuestionLabel)
        waitingBothView.addSubview(waitingImageView)
        waitingBothView.addSubview(waitingSubLabel)
        waitingBothView.addSubview(waitingButton)
        
        // 3. 상대만 보냄
        afterSettingContainerView.addSubview(partnerOnlyView)
        partnerOnlyView.addSubview(partnerQuestionLabel)
        partnerOnlyView.addSubview(partnerImageView)
        partnerImageView.addSubview(blurEffectView)
        partnerImageView.addSubview(partnerBadgeView)
        partnerBadgeView.addSubview(partnerProfileImageView)
        partnerBadgeView.addSubview(partnerNameLabel)
        partnerBadgeView.addSubview(partnerTimeLabel)
        partnerOnlyView.addSubview(partnerInfoLabel)
        partnerOnlyView.addSubview(partnerButton)
        
        // 4. 둘 다 보냄 (CombinedImageView만 추가) ✅
        afterSettingContainerView.addSubview(bothAnsweredView)
        bothAnsweredView.addSubview(combinedImageView)
        
        // 키워드 - 1. 둘 다 보냄
        afterSettingContainerView.addSubview(keywordBothView)
        keywordBothView.addSubview(keywordCombinedImageView)

        // 키워드 - 2. 내가 보냄
        afterSettingContainerView.addSubview(keywordMyOnlyView)
        keywordMyOnlyView.addSubview(myOnlyTopImageView)
        myOnlyTopImageView.addSubview(myOnlyOverlay)
        myOnlyTopImageView.addSubview(myOnlyProfileCircle)
        myOnlyTopImageView.addSubview(myOnlyNameLabel)
        myOnlyTopImageView.addSubview(myOnlyTimeLabel)
        myOnlyTopImageView.addSubview(myOnlyCaptionLabel)
        keywordMyOnlyView.addSubview(myOnlyBottomPlaceholder)
        keywordMyOnlyView.addSubview(myOnlyInfoLabel)
        keywordMyOnlyView.addSubview(myOnlyNotifyButton)

        // 키워드 - 3. 상대 보냄
        afterSettingContainerView.addSubview(keywordPartnerOnlyView)
        keywordPartnerOnlyView.addSubview(partnerOnlyTopPlaceholder)
        keywordPartnerOnlyView.addSubview(partnerOnlyInfoLabel)
        keywordPartnerOnlyView.addSubview(partnerOnlySendButton)
        keywordPartnerOnlyView.addSubview(partnerOnlyBottomImageView)
        partnerOnlyBottomImageView.addSubview(partnerOnlyOverlay)
        partnerOnlyBottomImageView.addSubview(partnerOnlyProfileCircle)
        partnerOnlyBottomImageView.addSubview(partnerOnlyNameLabel)
        partnerOnlyBottomImageView.addSubview(partnerOnlyTimeLabel)
        partnerOnlyBottomImageView.addSubview(partnerOnlyCaptionLabel)
    }
    
    override func setupConstraints() {
        setupBeforeSettingConstraints()
        setupAfterSettingConstraints()
    }
    
    private func setupBeforeSettingConstraints() {
        beforeSettingContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        setupButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
    }
    
    private func setupAfterSettingConstraints() {
        afterSettingContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.top.equalTo(afterSettingContainerView.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        // 1. 시간 전
        beforeTimeView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        beforeTimeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        beforeTimeImageView.snp.makeConstraints {
            $0.top.equalTo(beforeTimeLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        // 2. 둘 다 안보냄
        waitingBothView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        waitingQuestionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        waitingImageView.snp.makeConstraints {
            $0.top.equalTo(waitingQuestionLabel.snp.bottom).offset(42)
            $0.size.equalTo(167)
            $0.centerX.equalToSuperview()
        }
        
        waitingSubLabel.snp.makeConstraints {
            $0.top.equalTo(waitingImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        waitingButton.snp.makeConstraints {
            $0.top.equalTo(waitingSubLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 165, height: 48))
        }
        
        // 3. 상대만 보냄
        partnerOnlyView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        partnerQuestionLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        partnerImageView.snp.makeConstraints {
            $0.top.equalTo(partnerQuestionLabel.snp.bottom).offset(42)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(167) // waitingImageView와 동일한 크기
        }
        
        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        partnerBadgeView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        partnerProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        partnerNameLabel.snp.makeConstraints {
            $0.top.equalTo(partnerProfileImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        partnerTimeLabel.snp.makeConstraints {
            $0.top.equalTo(partnerNameLabel.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        partnerInfoLabel.snp.makeConstraints {
            $0.top.equalTo(partnerImageView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        partnerButton.snp.makeConstraints {
            $0.top.equalTo(partnerInfoLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        
        // 4. 둘 다 보냄 (CombinedImageView만 배치) ✅
        bothAnsweredView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        combinedImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        // 키워드 - 1. 둘 다 보냄
        keywordBothView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        keywordCombinedImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }

        // 키워드 - 2. 내가 보냄
        keywordMyOnlyView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        myOnlyTopImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }

        myOnlyOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        myOnlyProfileCircle.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }

        myOnlyNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(myOnlyProfileCircle)
            $0.leading.equalTo(myOnlyProfileCircle.snp.trailing).offset(8)
        }

        myOnlyTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(myOnlyProfileCircle)
            $0.leading.equalTo(myOnlyNameLabel.snp.trailing).offset(4)
        }

        myOnlyCaptionLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(16)
        }

        myOnlyBottomPlaceholder.snp.makeConstraints {
            $0.top.equalTo(myOnlyTopImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }

        myOnlyInfoLabel.snp.makeConstraints {
            $0.top.equalTo(myOnlyBottomPlaceholder.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        myOnlyNotifyButton.snp.makeConstraints {
            $0.top.equalTo(myOnlyInfoLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        // 키워드 - 3. 상대 보냄
        keywordPartnerOnlyView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        partnerOnlyTopPlaceholder.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(120)
        }

        partnerOnlyInfoLabel.snp.makeConstraints {
            $0.top.equalTo(partnerOnlyTopPlaceholder.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        partnerOnlySendButton.snp.makeConstraints {
            $0.top.equalTo(partnerOnlyInfoLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }

        partnerOnlyBottomImageView.snp.makeConstraints {
            $0.top.equalTo(partnerOnlySendButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(200)
        }

        partnerOnlyOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        partnerOnlyProfileCircle.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(16)
            $0.size.equalTo(24)
        }

        partnerOnlyNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(partnerOnlyProfileCircle)
            $0.leading.equalTo(partnerOnlyProfileCircle.snp.trailing).offset(8)
        }

        partnerOnlyTimeLabel.snp.makeConstraints {
            $0.centerY.equalTo(partnerOnlyProfileCircle)
            $0.leading.equalTo(partnerOnlyNameLabel.snp.trailing).offset(4)
        }

        partnerOnlyCaptionLabel.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(16)
        }
    }
    
    override func setupActions() {
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
        waitingButton.addTarget(self, action: #selector(sendPhotoTapped), for: .touchUpInside)
        partnerButton.addTarget(self, action: #selector(sendPhotoTapped), for: .touchUpInside)
    }
    
    @objc private func setupButtonTapped() {
        coordinator?.showKeywordSetting()
    }
    
    @objc private func sendPhotoTapped() {
        print("사진 전송하기")
    }
    
    func updateSettingStatus(isCompleted: Bool) {
        self.isSettingCompleted = isCompleted
        UserDefaults.standard.set(isCompleted, forKey: "isSettingCompleted")
        switchContainer()
    }
    
    private func switchContainer() {
        if isSettingCompleted {
            beforeSettingContainerView.isHidden = true
            afterSettingContainerView.isHidden = false
            
            let selectedKeyword = keywords[selectedKeywordIndex].text
            if selectedKeyword == "오늘의 질문" {
                updateQuestionUI()
            } else {
                updateKeywordUI(keyword: selectedKeyword)
            }
        } else {
            beforeSettingContainerView.isHidden = false
            afterSettingContainerView.isHidden = true
        }
    }
    
    private func updateQuestionUI() {
         hideAllViews()
         guard let question = currentQuestion else { return }
         
         switch question.status {
         case .beforeTime(let remainingTime):
             beforeTimeView.isHidden = false
             beforeTimeLabel.text = "오늘의 랜덤 질문이\n\(remainingTime) 후에 도착해요!"
             
         case .waitingBoth(let questionText):
             waitingBothView.isHidden = false
             waitingQuestionLabel.text = "Q.\n\(questionText)"
             
         case .partnerOnly(_, let questionText):
             questionPartnerOnlyView.isHidden = false
             partnerQuestionLabel.text = "Q.\n\(questionText)"
             
         case .bothAnswered(let myImageURL, let partnerImageURL, _):
             questionBothView.isHidden = false
             questionCombinedImageView.configure(
                 topImageURL: partnerImageURL,
                 topName: "성희",
                 topTime: "PM 12:30",
                 topCaption: "같이 산책 갔을 때 매",
                 bottomImageURL: myImageURL,
                 bottomName: "쏘피",
                 bottomTime: "PM 12:30",
                 bottomCaption: "같이 도서관 갔을 때 너무 사랑스러웠어!"
             )
         }
     }
     
    
    private func hideAllViews() {
        beforeTimeView.isHidden = true
        waitingBothView.isHidden = true
        questionPartnerOnlyView.isHidden = true
        questionBothView.isHidden = true
        keywordBothView.isHidden = true
        keywordMyOnlyView.isHidden = true
        keywordPartnerOnlyView.isHidden = true
    }
    
    
    private func updateKeywordUI(keyword: String) {
        hideAllViews()
        
        guard let keywordData = keywordDataDict[keyword],
              let status = keywordData.status else { return }
        
        switch status {
        case .bothAnswered(let myImageURL, let partnerImageURL, let myCaption, let partnerCaption):
            keywordBothView.isHidden = false
            keywordCombinedImageView.configure(
                topImageURL: partnerImageURL,
                topName: "jpg",
                topTime: "PM 12:30",
                topCaption: partnerCaption,
                bottomImageURL: myImageURL,
                bottomName: "쏘피",
                bottomTime: "PM 12:30",
                bottomCaption: myCaption
            )
            
        case .myAnswerOnly(_, let myCaption):
            keywordMyOnlyView.isHidden = false
            // myOnlyCaptionLabel.text = myCaption
            
        case .partnerOnly(_, let partnerCaption):
            keywordPartnerOnlyView.isHidden = false
            // partnerOnlyCaptionLabel.text = partnerCaption
        }
    }
    
    private func setupMockQuestion() {
        let scheduledTime = Date().addingTimeInterval(-100)
        
        currentQuestion = QuestionData(
            id: "1",
            question: "상대가 가장 사랑스러워 보였던 순간은 언제인가요?",
            scheduledTime: scheduledTime,
            myImageURL: "https://example.com/my.jpg",
            partnerImageURL: "https://example.com/partner.jpg"
        )
    }
    
    private func setupMockKeywordData() {
         keywordDataDict["맛집"] = KeywordData(
             keywordName: "맛집",
             myImageURL: "https://example.com/my_food.jpg",
             partnerImageURL: "https://example.com/partner_food.jpg",
             myCaption: "나는 떡볶이 먹고 진짜 좋았어!",
             partnerCaption: "그때 맛있었이? 오래됐네 맛집이야 ?"
         )
     }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let keyword = keywords[indexPath.item]
        let isSelected = indexPath.item == selectedKeywordIndex
        let cellData = KeywordCellData(keyword: keyword, isSelected: isSelected)
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: cellData
        )
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedKeywordIndex = indexPath.item
        collectionView.reloadData()
        
        let selectedKeyword = keywords[indexPath.item].text
        if selectedKeyword == "오늘의 질문" {
            updateQuestionUI()
        }
    }
}
