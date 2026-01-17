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
    
    // 데이터
    private var currentQuestion: QuestionData?
    private var keywordDataDict: [String: KeywordData] = [:]
    
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
    
    // MARK: - 오늘의 질문 View들 (4개)
    private let beforeTimeView = BeforeTimeView()
    private let waitingBothView = WaitingBothView()
    private let questionPartnerOnlyView = QuestionPartnerOnlyView()
    private let questionBothView = QuestionBothAnsweredView()
    
    // MARK: - 키워드 View들 (3개)
    private let keywordBothView = KeywordBothAnsweredView()
    private let keywordMyOnlyView = KeywordMyOnlyView()
    private let keywordPartnerOnlyView = KeywordPartnerOnlyView()
    
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
        setupMockKeywordData()
        setupCallbacks()
        checkInitialSettingStatus()
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
        
        // 오늘의 질문 View들 추가
        afterSettingContainerView.addSubview(beforeTimeView)
        afterSettingContainerView.addSubview(waitingBothView)
        afterSettingContainerView.addSubview(questionPartnerOnlyView)
        afterSettingContainerView.addSubview(questionBothView)
        
        // 키워드 View들 추가
        afterSettingContainerView.addSubview(keywordBothView)
        afterSettingContainerView.addSubview(keywordMyOnlyView)
        afterSettingContainerView.addSubview(keywordPartnerOnlyView)
        
        // 초기 상태: 모두 숨김
        hideAllViews()
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
        
        // 7개 View 모두 동일한 constraints (CollectionView 아래 꽉 채우기)
        [beforeTimeView, waitingBothView, questionPartnerOnlyView, questionBothView,
         keywordBothView, keywordMyOnlyView, keywordPartnerOnlyView].forEach { view in
            view.snp.makeConstraints {
                $0.top.equalTo(keywordCollectionView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            }
        }
    }
    
    override func setupActions() {
        setupButton.addTarget(self, action: #selector(setupButtonTapped), for: .touchUpInside)
    }
    
    private func checkInitialSettingStatus() {
        isSettingCompleted = UserDefaults.standard.bool(forKey: "isSettingCompleted")
        print("🔴 [HomeVC] 초기 체크 - isSettingCompleted: \(isSettingCompleted)")
        
        switchContainer()
        
        if !isSettingCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.coordinator?.showInviteModal()
            }
        }
    }
    
    private func setupCallbacks() {
        waitingBothView.onSendPhotoTapped = { [weak self] in
            guard let self else { return }
            print("사진 전송하기")
            self.coordinator?.showCameraModal()
        }
        
        // QuestionPartnerOnlyView 콜백
        questionPartnerOnlyView.onAnswerTapped = { [weak self] in
            guard let self else { return }
            print("나도 답변하기")
            // TODO: 카메라 열기
            self.coordinator?.showCameraModal()
        }
        
        // KeywordMyOnlyView 콜백
        keywordMyOnlyView.onNotifyTapped = { [weak self] in
            guard let self else { return }
            print("콕 찌르기")
            CustomAlertViewController.show(
                on: self,
                title: "콕 찌르기 완료!",
                message: "상대방의 사진이 도착하면\n알림을 보내드릴게요.",
                confirmTitle: "확인"
            ) {
                print("확인 버튼 클릭!")
            }
        }
        
        // KeywordPartnerOnlyView 콜백
        keywordPartnerOnlyView.onSendPhotoTapped = { [weak self] in
            guard let self else { return }
            print("전송하러 가기")
            // TODO: 카메라 열기
            self.coordinator?.showCameraModal()
        }
    }
    
    @objc private func setupButtonTapped() {
        coordinator?.showKeywordSetting()
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                
                self?.coordinator?.showInviteModal()
            }
        }
    }
    
    // MARK: - 오늘의 질문 UI 업데이트
    private func updateQuestionUI() {
        hideAllViews()
        guard let question = currentQuestion else { return }
        
        switch question.status {
        case .beforeTime(let remainingTime):
            beforeTimeView.isHidden = false
            beforeTimeView.configure(remainingTime: remainingTime)
            
        case .waitingBoth(let questionText):
            waitingBothView.isHidden = false
            waitingBothView.configure(question: questionText)
            
        case .partnerOnly(let imageURL, let questionText):
            questionPartnerOnlyView.isHidden = false
            questionPartnerOnlyView.configure(question: "상대가 가장 사랑스러워 보였던\n순간은 언제인가요?", subTitle: "상대방이 어떤 사진을 보냈는을까요?\n내 사진을 공유하면\n상대방의 사진도 확인할 수 있어요.", partnerName: "jpg", partnerImageURL: imageURL, partmerTime: "PM 12:30")
            
        case .bothAnswered(let myURL, let partnerURL, _):
            questionBothView.isHidden = false
            questionBothView.configure(
                myImageURL: myURL,
                myName: "쏘피",
                myTime: "PM 12:30",
                myCaption: "같이 도서관 갔을 때 너무 사랑스러웠어!",
                partnerImageURL: partnerURL,
                partnerName: "성희",
                partnerTime: "PM 12:30",
                partnerCaption: "같이 산책 갔을 때 매"
            )
        }
    }
    
    // MARK: - 키워드 UI 업데이트
    private func updateKeywordUI(keyword: String) {
        hideAllViews()
        
        guard let keywordData = keywordDataDict[keyword],
              let status = keywordData.status else { return }
        
        switch status {
        case .bothAnswered(let myURL, let partnerURL, let myCap, let partnerCap):
            keywordBothView.isHidden = false
            keywordBothView.configure(
                myImageURL: myURL,
                myName: "쏘피",
                myTime: "PM 12:30",
                myCaption: myCap,
                partnerImageURL: partnerURL,
                partnerName: "jpg",
                partnerTime: "PM 12:30",
                partnerCaption: partnerCap
            )
            
        case .myAnswerOnly(let myURL, let myCap):
            keywordMyOnlyView.isHidden = false
            keywordMyOnlyView.configure(
                myImageURL: myURL,
                myName: "쏘피",
                myTime: "PM 12:30",
                myCaption: myCap
            )
            
        case .partnerOnly(let partnerURL, let partnerCap):
            keywordPartnerOnlyView.isHidden = false
            keywordPartnerOnlyView.configure(
                partnerImageURL: partnerURL,
                partnerName: "jpg",
                partnerTime: "PM 12:30",
                partnerCaption: partnerCap,
                myName: "쏘피"
            )
        }
    }
    
    private func hideAllViews() {
        [beforeTimeView, waitingBothView, questionPartnerOnlyView, questionBothView,
         keywordBothView, keywordMyOnlyView, keywordPartnerOnlyView].forEach {
            $0.isHidden = true
        }
    }
    
    // MARK: - Mock Data
    private func setupMockQuestion() {
        let scheduledTime = Date().addingTimeInterval(-100)
        
        currentQuestion = QuestionData(
            id: "1",
            question: "상대가 가장 사랑스러워 보였던 순간은 언제인가요?",
            scheduledTime: scheduledTime,
            myImageURL: nil,
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
        
        keywordDataDict["여행"] = KeywordData(
            keywordName: "여행",
            myImageURL: "https://example.com/my_travel.jpg",
            partnerImageURL: nil,
            myCaption: "제주도 여행 너무 좋았어!",
            partnerCaption: nil
        )
        
        keywordDataDict["데이트"] = KeywordData(
            keywordName: "데이트",
            myImageURL: nil,
            partnerImageURL: "https://example.com/partner_date.jpg",
            myCaption: nil,
            partnerCaption: "오늘 데이트 너무 행복했어!"
        )
    }
}

// MARK: - CollectionView
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
        } else {
            updateKeywordUI(keyword: selectedKeyword)
        }
    }
}
