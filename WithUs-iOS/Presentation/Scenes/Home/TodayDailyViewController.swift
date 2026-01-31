//
//  TodayDailyViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import ReactorKit
import RxSwift
import RxCocoa

final class TodayDailyViewController: BaseViewController, ReactorKit.View {
    var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    
    private var keywords: [Keyword] = []
    private var selectedKeywordIndex: Int = 0
    private weak var currentPhotoPreview: PhotoPreviewViewController?
    
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
    
    private let contentContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let waitingBothView = WaitingBothView()
    private let keywordMyOnlyView = KeywordMyOnlyView()
    private let keywordPartnerOnlyView = KeywordPartnerOnlyView()
    private let keywordBothView = KeywordBothAnsweredView()
    
    private lazy var allContentViews: [UIView] = [
        waitingBothView,
        keywordMyOnlyView,
        keywordPartnerOnlyView,
        keywordBothView
    ]
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(keywordCollectionView)
        view.addSubview(contentContainerView)
        allContentViews.forEach { contentContainerView.addSubview($0) }
        hideAllContentViews()
    }
    
    override func setupConstraints() {
        keywordCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(keywordCollectionView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        allContentViews.forEach { view in
            view.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    override func setupActions() {
        setupCallbacks()
    }
    
    // MARK: - Reactor Binding
    func bind(reactor: TodayDailyReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State: 키워드 리스트
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
        
        // State: 선택된 키워드 인덱스
        reactor.state.map { $0.selectedKeywordIndex }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.selectedKeywordIndex = index
                self?.keywordCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // State: 오늘의 일상 키워드 데이터
        reactor.state.map { $0.currentKeywordData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateDailyUI(with: data)
            })
            .disposed(by: disposeBag)
        
        // State: 이미지 업로드 성공
        reactor.state.map { $0.uploadedImageUrl }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageKey in
                print("✅ 일상 이미지 업로드 완료: \(imageKey)")
                self?.currentPhotoPreview?.showUploadSuccess()
            })
            .disposed(by: disposeBag)
        
        // State: 에러
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("❌ 일상 에러: \(error)")
                self?.currentPhotoPreview?.showUploadFail()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Update
    private func updateDailyUI(with data: TodayKeywordResponse) {
        hideAllContentViews()
        
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
                myProfileURL: data.myInfo?.profileImageUrl ?? ""
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
    
    private func hideAllContentViews() {
        allContentViews.forEach { $0.isHidden = true }
    }
    
    // MARK: - Camera
    private func openCameraForKeyword() {
        guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
            print("❌ coupleKeywordId가 없습니다")
            return
        }
        coordinator?.showCamera(for: .keyword(coupleKeywordId: coupleKeywordId), delegate: self)
    }
    
    // MARK: - Callbacks
    private func setupCallbacks() {
        waitingBothView.onSendPhotoTapped = { [weak self] in
            self?.openCameraForKeyword()
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

// MARK: - CollectionView DataSource
extension TodayDailyViewController: UICollectionViewDataSource {
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

// MARK: - CollectionView Delegate
extension TodayDailyViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let coupleKeywordId = Int(keywords[indexPath.item].id) else { return }
        reactor?.action.onNext(.selectKeyword(coupleKeywordId: coupleKeywordId, index: indexPath.item))
    }
}

// MARK: - PhotoPreview Delegate
extension TodayDailyViewController: PhotoPreviewDelegate {
    func photoPreview(_ viewController: PhotoPreviewViewController, didSelectImage image: UIImage) {
        currentPhotoPreview = viewController
        
        guard let coupleKeywordId = reactor?.currentState.currentKeywordData?.coupleKeywordId else {
            viewController.showUploadFail()
            return
        }
        reactor?.action.onNext(.uploadKeywordImage(coupleKeywordId: coupleKeywordId, image: image))
    }
}
