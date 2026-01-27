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
    
    private var keywords: [Keyword] = []
    private var selectedKeywordIndex: Int = 0
    private weak var currentPhotoPreview: PhotoPreviewViewController?
    
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
    
    // MARK: - After Setting UI
    private lazy var keywordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.showsHorizontalScrollIndicator = false
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    // MARK: - 오늘의 질문 View들
    private let beforeTimeView = BeforeTimeView()
    private let waitingBothView = WaitingBothView()
    private let questionPartnerOnlyView = QuestionPartnerOnlyView()
    private let questionBothView = QuestionBothAnsweredView()
    
    // MARK: - 키워드 View들
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
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(beforeSettingContainerView)
        view.addSubview(afterSettingContainerView)
        
        beforeSettingContainerView.addSubview(settingCoupleView)
        beforeSettingContainerView.addSubview(settingInviteCodeView)
        
        afterSettingContainerView.addSubview(keywordCollectionView)
        afterSettingContainerView.addSubview(beforeTimeView)
        afterSettingContainerView.addSubview(waitingBothView)
        afterSettingContainerView.addSubview(questionPartnerOnlyView)
        afterSettingContainerView.addSubview(questionBothView)
        afterSettingContainerView.addSubview(keywordBothView)
        afterSettingContainerView.addSubview(keywordMyOnlyView)
        afterSettingContainerView.addSubview(keywordPartnerOnlyView)
        
        hideContentViews()
        hideSettingViews()
    }
    
    override func setupConstraints() {
        beforeSettingContainerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        [settingCoupleView, settingInviteCodeView].forEach { view in
            view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        afterSettingContainerView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        keywordCollectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        [beforeTimeView, waitingBothView, questionPartnerOnlyView, questionBothView,
         keywordBothView, keywordMyOnlyView, keywordPartnerOnlyView].forEach { view in
            view.snp.makeConstraints {
                $0.top.equalTo(keywordCollectionView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }
        }
    }
    
    override func setNavigation() {
        setRightBarButton(image: UIImage(named: "ic_bell"))
        setCenterLogo(image: UIImage(named: "navi_logo"), height: 24)
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
        
        reactor.state.map { $0.onboardingStatus }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] status in
                self?.handleOnboardingStatus(status)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.keywords }
            .distinctUntilChanged { lhs, rhs in
                lhs.map { $0.id } == rhs.map { $0.id }
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] keywords in
                self?.keywords = keywords
                self?.keywordCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedKeywordIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.selectedKeywordIndex = index
                self?.keywordCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.currentQuestionData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateQuestionUI(with: data)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.currentKeywordData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateKeywordUI(with: data)
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
        
        reactor.state.map { $0.uploadedImageUrl }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] accessUrl in
                print("✅ 이미지 업로드 완료: \(accessUrl)")
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
            showBeforeSettingUI()
            setInvite()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.coordinator?.showInviteModal()
            }
            
        case .needCoupleSetup:
            showBeforeSettingUI()
            setCouple()
            
        case .completed:
            showAfterSettingUI()
            reactor?.action.onNext(.fetchCoupleKeywords)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.reactor?.action.onNext(.selectDefaultKeyword)
            }
        }
    }
    
    // MARK: - UI State
    private func showBeforeSettingUI() {
        beforeSettingContainerView.isHidden = false
        afterSettingContainerView.isHidden = true
    }
    
    private func showAfterSettingUI() {
        beforeSettingContainerView.isHidden = true
        afterSettingContainerView.isHidden = false
    }
    
    private func setInvite() {
        hideContentViews()
        settingInviteCodeView.isHidden = false
    }
    
    private func setCouple() {
        hideContentViews()
        settingCoupleView.isHidden = false
    }
    
    private func hideContentViews() {
        [beforeTimeView, waitingBothView, questionPartnerOnlyView, questionBothView,
         keywordBothView, keywordMyOnlyView, keywordPartnerOnlyView].forEach {
            $0.isHidden = true
        }
    }
    
    private func hideSettingViews() {
        [settingCoupleView, settingInviteCodeView].forEach {
            $0.isHidden = true
        }
    }
    
    // MARK: - Update UI
    private func updateQuestionUI(with data: TodayQuestionResponse) {
        hideContentViews()
        hideSettingViews()
        
        // coupleQuestionId가 nil이면 질문 생성 전
        guard let _ = data.coupleQuestionId else {
            beforeTimeView.isHidden = false
            beforeTimeView.configure(remainingTime: data.question)
            return
        }
        
        let myAnswered = data.myInfo?.questionImageUrl != nil
        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        
        switch (myAnswered, partnerAnswered) {
        case (false, false):
            waitingBothView.isHidden = false
            waitingBothView.configure(question: data.question)
            
        case (false, true):
            questionPartnerOnlyView.isHidden = false
            questionPartnerOnlyView.configure(
                question: data.question,
                subTitle: "상대방이 어떤 사진을 보냈는을까요?\n내 사진을 공유하면\n상대방의 사진도 확인할 수 있어요.",
                partnerName: data.partnerInfo?.name ?? "",
                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
                partmerTime: data.partnerInfo?.answeredAt ?? ""
            )
            
        case (true, false):
            keywordMyOnlyView.isHidden = false
            keywordMyOnlyView.configure(
                myImageURL: data.myInfo?.questionImageUrl ?? "",
                myName: data.myInfo?.name ?? "",
                myTime: data.myInfo?.answeredAt ?? "",
                myProfileURL: data.question
            )
            
        case (true, true):
            questionBothView.isHidden = false
            questionBothView.configure(
                myImageURL: data.myInfo?.questionImageUrl ?? "",
                myName: data.myInfo?.name ?? "",
                myTime: data.myInfo?.answeredAt ?? "",
                myCaption: data.question,
                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
                partnerName: data.partnerInfo?.name ?? "",
                partnerTime: data.partnerInfo?.answeredAt ?? "",
                partnerCaption: data.question
            )
        }
    }
    
    private func updateKeywordUI(with data: TodayKeywordResponse) {
        hideContentViews()
        hideSettingViews()
        
        let myAnswered = data.myInfo?.questionImageUrl != nil
        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        
        switch (myAnswered, partnerAnswered) {
        case (false, false):
            waitingBothView.isHidden = false
            waitingBothView.configure(question: data.question)
            
        case (false, true):
            keywordPartnerOnlyView.isHidden = false
            keywordPartnerOnlyView.configure(
                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
                partnerName: data.partnerInfo?.name ?? "",
                partnerTime: data.partnerInfo?.answeredAt ?? "",
                partnerCaption: data.question,
                myName: data.myInfo?.name ?? ""
            )
            
        case (true, false):
            keywordMyOnlyView.isHidden = false
            keywordMyOnlyView.configure(
                myImageURL: data.myInfo?.questionImageUrl ?? "",
                myName: data.myInfo?.name ?? "",
                myTime: data.myInfo?.answeredAt ?? "",
                myProfileURL: data.myInfo?.profileImageUrl ?? "",
            )
            
        case (true, true):
            keywordBothView.isHidden = false
            keywordBothView.configure(
                myImageURL: data.myInfo?.questionImageUrl ?? "",
                myName: data.myInfo?.name ?? "",
                myTime: data.myInfo?.answeredAt ?? "",
                myCaption: data.question,
                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
                partnerName: data.partnerInfo?.name ?? "",
                partnerTime: data.partnerInfo?.answeredAt ?? "",
                partnerCaption: data.question
            )
        }
    }
    
    // MARK: - Camera
    private func openCameraForQuestion() {
        guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
            print("❌ coupleQuestionId가 없습니다")
            return
        }
        
        // ✅ 업로드 타입과 함께 카메라 열기
        coordinator?.showCamera(for: .question(coupleQuestionId: coupleQuestionId), delegate: self)
    }
    
    private func openCameraForKeyword() {
        guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
            print("❌ coupleKeywordId가 없습니다")
            return
        }
        
        // ✅ 업로드 타입과 함께 카메라 열기
        coordinator?.showCamera(for: .keyword(coupleKeywordId: coupleKeywordId), delegate: self)
    }
    
    // MARK: - Callbacks
    private func setupCallbacks() {
        settingCoupleView.onTap = { [weak self] in
            self?.coordinator?.showInviteModal()
        }
        
        settingInviteCodeView.onTap = { [weak self] in
            self?.coordinator?.showInviteModal()
        }
        
        waitingBothView.onSendPhotoTapped = { [weak self] in
            guard let self = self else { return }
            if self.keywords[self.selectedKeywordIndex].id == "today_question" {
                self.openCameraForQuestion()
            } else {
                self.openCameraForKeyword()
            }
        }
        
        questionPartnerOnlyView.onAnswerTapped = { [weak self] in
            self?.openCameraForQuestion()
        }
        
        keywordPartnerOnlyView.onSendPhotoTapped = { [weak self] in
            self?.openCameraForKeyword()
        }
        
        keywordMyOnlyView.onNotifyTapped = { [weak self] in
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
        reactor?.action.onNext(.selectKeyword(index: indexPath.item))
    }
}

extension HomeViewController: PhotoPreviewDelegate {
    func photoPreview(_ viewController: PhotoPreviewViewController, didSelectImage image: UIImage) {
        currentPhotoPreview = viewController
        
        if keywords[selectedKeywordIndex].id == "today_question" {
            guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
                viewController.showUploadFail()
                return
            }
            
            reactor?.action.onNext(.uploadQuestionImage(
                coupleQuestionId: coupleQuestionId,
                image: image
            ))
        } else {
            guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
                viewController.showUploadFail()
                return
            }
            
            reactor?.action.onNext(.uploadKeywordImage(
                coupleKeywordId: coupleKeywordId,
                image: image
            ))
        }
    }
}
