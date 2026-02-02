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
import ReactorKit
import RxSwift
import RxCocoa

final class HomeViewController: BaseViewController, ReactorKit.View {
    var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    
    // MARK: - Data
    private var keywords: [Keyword] = []
    private let fixedKeywords = ["오늘의 질문", "오늘의 일상"]
    private var selectedKeywordIndex: Int = 0
    private var currentDailyPageIndex: Int = 0
    private weak var currentPhotoPreview: PhotoPreviewViewController?
    
    // MARK: - View State Management
    private enum ViewState {
        case needInviteCode
        case needCoupleSetup
        case questionContent
        case dailyContent
    }
    
    private var currentViewState: ViewState = .questionContent {
        didSet {
            updateViewVisibility()
        }
    }
    
    // MARK: - Container Views
    private let beforeSettingContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let afterSettingContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    // MARK: - Before Setting UI
    private let settingInviteCodeView = SettingInviteCodeView()
    private let settingCoupleView = SettingCoupleView()
    
    // MARK: - After Setting UI - 상단 탭
    private lazy var keywordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - Content Container
    private let contentContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    // MARK: - All Content Views (하나의 배열로 관리)
    private lazy var allContentViews: [UIView] = [
        beforeTimeView,
        waitingBothView,
        questionPartnerOnlyView,
        questionBothView,
        settingCoupleViewForDaily,
        dailyPageCollectionView,
        pageControl
    ]
    
    private let beforeTimeView = BeforeTimeView()
    private let waitingBothView = WaitingBothView()
    private let questionPartnerOnlyView = QuestionPartnerOnlyView()
    private let questionBothView = QuestionBothAnsweredView()
    private let settingCoupleViewForDaily = SettingCoupleView()
    
    private lazy var dailyPageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        cv.register(DailyKeywordCell.self, forCellWithReuseIdentifier: "DailyKeywordCell")
        return cv
    }()
    
    private let pageControl = UIPageControl().then {
        $0.currentPageIndicatorTintColor = UIColor.gray900
        $0.pageIndicatorTintColor = UIColor.gray300
        $0.numberOfPages = 3
        $0.preferredIndicatorImage = UIImage(named: "page_control_inactive")
        $0.setIndicatorImage(UIImage(named: "page_control_active"), forPage: 0)
    }
    
    private var cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, KeywordCellData> { cell, indexPath, item in
        cell.contentConfiguration = UIHostingConfiguration {
            KeywordCellView(
                keyword: item.keyword.text,
                isSelected: item.isSelected,
                isAddButton: false
            )
        }
        .margins(.all, 0)
        .background(Color.clear)
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(beforeSettingContainerView)
        view.addSubview(afterSettingContainerView)
        
        // Before Setting
        beforeSettingContainerView.addSubview(settingInviteCodeView)
        
        // After Setting
        afterSettingContainerView.addSubview(keywordCollectionView)
        afterSettingContainerView.addSubview(contentContainerView)
        
        // Content Views (한 곳에 모두 추가)
        allContentViews.forEach { contentContainerView.addSubview($0) }
        
        // 초기 상태: 모두 숨김
        hideAllContentViews()
    }
    
    override func setupConstraints() {
        beforeSettingContainerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        settingInviteCodeView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        afterSettingContainerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.height.equalTo(64)
            $0.width.equalTo(250)
            $0.top.centerX.equalToSuperview()
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        // Content Views 제약조건 (공통)
        [beforeTimeView, waitingBothView, questionPartnerOnlyView, questionBothView,
         settingCoupleViewForDaily, dailyPageCollectionView].forEach { view in
            view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        // PageControl만 별도 위치
        pageControl.snp.remakeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(32)
            $0.height.equalTo(20)
        }
    }
    
    override func setNavigation() {
        setRightBarButton(image: UIImage(named: "ic_bell"))
        
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "WITHUS", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
    }
    
    override func setupActions() {
        setupCallbacks()
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: HomeReactor) {
        // Action: 화면 진입
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State: 온보딩 상태
        reactor.state.map { $0.onboardingStatus }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.handleOnboardingStatus(status)
            })
            .disposed(by: disposeBag)
        
        // State: 키워드 리스트
        reactor.state.map { $0.keywords }
            .distinctUntilChanged { lhs, rhs in
                lhs.map { $0.id } == rhs.map { $0.id }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keywords in
                self?.keywords = keywords
                self?.updatePageControl()
                self?.dailyPageCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // State: 선택된 상단 탭 인덱스
        reactor.state.map { $0.selectedKeywordIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.selectedKeywordIndex = index
                self?.keywordCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // State: 오늘의 질문 데이터
        reactor.state.map { $0.currentQuestionData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateQuestionUI(with: data)
            })
            .disposed(by: disposeBag)
        
        // State: 오늘의 일상 데이터
        reactor.state.map { $0.currentKeywordData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.currentViewState = .dailyContent
                self?.dailyPageCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // State: needCoupleSetup에서 "오늘의 일상" 선택
        reactor.state.map { $0.shouldShowDailyCoupleSetup }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                guard shouldShow else { return }
                self?.currentViewState = .needCoupleSetup
            })
            .disposed(by: disposeBag)
        
        // State: 에러
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("❌ 에러: \(error)")
                self?.currentPhotoPreview?.showUploadFail()
            })
            .disposed(by: disposeBag)
        
        // State: 이미지 업로드 성공
        reactor.state.map { $0.uploadedImageUrl }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageKey in
                print("✅ 이미지 업로드 완료: \(imageKey)")
                self?.currentPhotoPreview?.showUploadSuccess()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Handle Onboarding Status
    private func handleOnboardingStatus(_ status: OnboardingStatus) {
        switch status {
        case .needUserSetup:
            coordinator?.handleNeedUserSetup()
            
        case .needCoupleConnect:
            currentViewState = .needInviteCode
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.coordinator?.showInviteModal()
            }
            
        case .completed:
            beforeSettingContainerView.isHidden = true
            afterSettingContainerView.isHidden = false
            reactor?.action.onNext(.selectDefaultKeyword)
        }
    }
    
    // MARK: - View Visibility Management (핵심!)
    private func updateViewVisibility() {
        // 1단계: 모든 뷰 숨김
        hideAllContentViews()
        
        // 2단계: 상태별로 필요한 컨테이너만 표시
        switch currentViewState {
        case .needInviteCode:
            beforeSettingContainerView.isHidden = false
            afterSettingContainerView.isHidden = true
            settingInviteCodeView.isHidden = false
            
        case .needCoupleSetup:
            beforeSettingContainerView.isHidden = true
            afterSettingContainerView.isHidden = false
            settingCoupleViewForDaily.isHidden = false
            
        case .questionContent:
            beforeSettingContainerView.isHidden = true
            afterSettingContainerView.isHidden = false
            // questionUI는 updateQuestionUI에서 개별 처리
            
        case .dailyContent:
            beforeSettingContainerView.isHidden = true
            afterSettingContainerView.isHidden = false
            dailyPageCollectionView.isHidden = false
            pageControl.isHidden = false
        }
    }
    
    private func hideAllContentViews() {
        allContentViews.forEach { $0.isHidden = true }
        settingInviteCodeView.isHidden = true
    }
    
    // MARK: - Update UI
    private func updateQuestionUI(with data: TodayQuestionResponse) {
        currentViewState = .questionContent
        
        guard data.coupleQuestionId != nil else {
            show(view: beforeTimeView)
            beforeTimeView.configure(remainingTime: data.question)
            return
        }
        
        let myAnswered = data.myInfo?.questionImageUrl != nil
        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        
        switch (myAnswered, partnerAnswered) {
        case (false, false):
            show(view: waitingBothView)
            waitingBothView.configure(question: data.question)
            
        case (false, true):
            show(view: questionPartnerOnlyView)
//            questionPartnerOnlyView.configure(
//                question: data.question,
//                subTitle: "상대방이 어떤 사진을 보냈는을까요?\n내 사진을 공유하면\n상대방의 사진도 확인할 수 있어요.",
//                partnerName: data.partnerInfo?.name ?? "",
//                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
//                partmerTime: data.partnerInfo?.answeredAt ?? ""
//            )
            
        case (true, false):
            // TODO: MyOnly 처리 필요시 추가
            break
            
        case (true, true):
            show(view: questionBothView)
//            questionBothView.configure(
//                myImageURL: data.myInfo?.questionImageUrl ?? "",
//                myName: data.myInfo?.name ?? "",
//                myTime: data.myInfo?.answeredAt ?? "",
//                myCaption: data.question,
//                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
//                partnerName: data.partnerInfo?.name ?? "",
//                partnerTime: data.partnerInfo?.answeredAt ?? "",
//                partnerCaption: data.question
//            )
        }
    }
    
    private func show(view: UIView) {
        view.isHidden = false
    }
    
    private func updatePageControl() {
        pageControl.numberOfPages = keywords.count
        pageControl.currentPage = currentDailyPageIndex
    }
    
    // MARK: - Camera
    private func openCameraForQuestion() {
        guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
            print("❌ coupleQuestionId가 없습니다")
            return
        }
        coordinator?.showCamera(for: .question(coupleQuestionId: coupleQuestionId), delegate: self)
    }
    
    private func openCameraForKeyword() {
        guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
            print("❌ coupleKeywordId가 없습니다")
            return
        }
        coordinator?.showCamera(for: .keyword(coupleKeywordId: coupleKeywordId), delegate: self)
    }
    
    // MARK: - Callbacks
    private func setupCallbacks() {
        settingCoupleViewForDaily.onTap = { [weak self] in
//            self?.coordinator?.showInviteModal()
            
        }
        
        settingInviteCodeView.onTap = { [weak self] in
            self?.coordinator?.showInviteModal()
        }
        
        settingCoupleViewForDaily.onTap = { [weak self] in
            self?.coordinator?.showKeywordModification()
        }
        
        waitingBothView.onSendPhotoTapped = { [weak self] in
            guard let self = self else { return }
            self.selectedKeywordIndex == 0 ? self.openCameraForQuestion() : self.openCameraForKeyword()
        }
        
        questionPartnerOnlyView.onAnswerTapped = { [weak self] in
            self?.openCameraForQuestion()
        }
    }
}

// MARK: - CollectionView DataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == keywordCollectionView ? fixedKeywords.count : keywords.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == keywordCollectionView {
            let keyword = Keyword(
                id: indexPath.item == 0 ? "today_question" : "today_daily",
                text: fixedKeywords[indexPath.item],
                displayOrder: indexPath.item
            )
            let isSelected = indexPath.item == selectedKeywordIndex
            let cellData = KeywordCellData(keyword: keyword, isSelected: isSelected)
            
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: cellData
            )
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DailyKeywordCell",
                for: indexPath
            ) as! DailyKeywordCell
            
            if indexPath.item == currentDailyPageIndex,
               let data = reactor?.currentState.currentKeywordData {
                cell.configure(with: data)
            } else {
                cell.reset()
            }
            
            cell.onSendPhotoTapped = { [weak self] in
                self?.openCameraForKeyword()
            }
            
            cell.onNotifyTapped = { [weak self] in
                guard let self = self else { return }
                let partnerUserId = self.reactor?.currentState.currentKeywordData?.partnerInfo?.userId ?? 0
                print("콕 찌르기 - Partner ID: \(partnerUserId)")
                
                CustomAlertViewController.show(
                    on: self,
                    title: "콕 찌르기 완료!",
                    message: "상대방의 사진이 도착하면\n알림을 보내드릴게요.",
                    confirmTitle: "확인"
                ) {}
            }
            
            return cell
        }
    }
}

// MARK: - CollectionView Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView == dailyPageCollectionView ? collectionView.bounds.size : .zero
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == dailyPageCollectionView else { return }
        
        let pageWidth = scrollView.frame.width
        let newPageIndex = Int(scrollView.contentOffset.x / pageWidth)
        
        guard newPageIndex != currentDailyPageIndex else { return }
        
        currentDailyPageIndex = newPageIndex
        pageControl.currentPage = newPageIndex
        
        guard let coupleKeywordId = Int(keywords[newPageIndex].id) else { return }
        reactor?.action.onNext(.loadDailyKeyword(coupleKeywordId: coupleKeywordId, pageIndex: newPageIndex))
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == keywordCollectionView else { return }
        reactor?.action.onNext(.selectKeyword(index: indexPath.item))
    }
}

// MARK: - PhotoPreview Delegate
extension HomeViewController: PhotoPreviewDelegate {
    func photoPreview(_ viewController: PhotoPreviewViewController, didSelectImage image: UIImage) {
        currentPhotoPreview = viewController
        
        if selectedKeywordIndex == 0 {
            guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
                viewController.showUploadFail()
                return
            }
            reactor?.action.onNext(.uploadQuestionImage(coupleQuestionId: coupleQuestionId, image: image))
        } else {
            guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
                viewController.showUploadFail()
                return
            }
            reactor?.action.onNext(.uploadKeywordImage(coupleKeywordId: coupleKeywordId, image: image))
        }
    }
}
