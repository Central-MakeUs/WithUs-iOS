//
//  TodayQuestionViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class TodayQuestionViewController: BaseViewController, ReactorKit.View {
    var coordinator: HomeCoordinator?
    var disposeBag = DisposeBag()
    
    private weak var currentPhotoPreview: PhotoPreviewViewController?
    
    private let contentContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let beforeTimeView = BeforeTimeView()
    private let waitingBothView = WaitingBothView()
    private let questionPartnerOnlyView = QuestionPartnerOnlyView()
    private let questionBothView = QuestionBothAnsweredView()
    
    private lazy var allContentViews: [UIView] = [
        beforeTimeView,
        waitingBothView,
        questionPartnerOnlyView,
        questionBothView
    ]
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(contentContainerView)
        allContentViews.forEach { contentContainerView.addSubview($0) }
        hideAllContentViews()
    }
    
    override func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        allContentViews.forEach { view in
            view.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(26)
                $0.top.equalToSuperview().offset(38)
                $0.bottom.equalToSuperview().offset(-27)
            }
        }
    }
    
    override func setupActions() {
        setupCallbacks()
    }
    
    func bind(reactor: TodayQuestionReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.currentQuestionData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] data in
                self?.updateQuestionUI(with: data)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.uploadedImageUrl }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] imageKey in
                print("✅ 질문 이미지 업로드 완료: \(imageKey)")
                self?.currentPhotoPreview?.showUploadSuccess()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                print("❌ 질문 에러: \(error)")
                self?.currentPhotoPreview?.showUploadFail()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Update
    private func updateQuestionUI(with data: TodayQuestionResponse) {
        hideAllContentViews()
        
        guard data.coupleQuestionId != nil else {
            beforeTimeView.isHidden = false
            beforeTimeView.configure(remainingTime: data.question)
            return
        }
        
//        let myAnswered = data.myInfo?.questionImageUrl != nil
        let myAnswered: Bool = true
//        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        let partnerAnswered: Bool = true
        
        switch (myAnswered, partnerAnswered) {
        case (false, false):
            waitingBothView.isHidden = false
            waitingBothView.configure(question: data.question)
            
        case (false, true):
            questionPartnerOnlyView.isHidden = false
            let question = data.question
            let name = data.partnerInfo?.name ?? ""
            let profile = data.partnerInfo?.profileImageUrl ?? ""
            let image = data.partnerInfo?.questionImageUrl ?? ""
            let time = data.partnerInfo?.answeredAt ?? ""
            
            questionPartnerOnlyView.configure(
                question: question,
                name: name,
                profile: profile,
                image: image,
                time: time
            )
            
        case (true, false):
            break
            
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
    
    private func hideAllContentViews() {
        allContentViews.forEach { $0.isHidden = true }
    }
    
    // MARK: - Camera
    private func openCameraForQuestion() {
        guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
            print("❌ coupleQuestionId가 없습니다")
            return
        }
        coordinator?.showCamera(for: .question(coupleQuestionId: coupleQuestionId), delegate: self)
    }
    
    // MARK: - Callbacks
    private func setupCallbacks() {
        waitingBothView.onSendPhotoTapped = { [weak self] in
            self?.openCameraForQuestion()
        }
        
        questionPartnerOnlyView.onAnswerTapped = { [weak self] in
            self?.openCameraForQuestion()
        }
    }
}

// MARK: - PhotoPreview Delegate
extension TodayQuestionViewController: PhotoPreviewDelegate {
    func photoPreview(_ viewController: PhotoPreviewViewController, didSelectImage image: UIImage) {
        currentPhotoPreview = viewController
        
        guard let coupleQuestionId = reactor?.currentState.currentQuestionData?.coupleQuestionId else {
            viewController.showUploadFail()
            return
        }
        reactor?.action.onNext(.uploadQuestionImage(coupleQuestionId: coupleQuestionId, image: image))
    }
}
