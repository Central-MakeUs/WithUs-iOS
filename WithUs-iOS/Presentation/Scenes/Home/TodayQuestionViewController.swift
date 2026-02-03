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
    private let questionMyOnlyView = KeywordMyOnlyView()
    private let questionPartnerOnlyView = QuestionPartnerOnlyView()
    private let questionBothView = QuestionBothAnsweredView()
    
    private lazy var allContentViews: [UIView] = [
        beforeTimeView,
        waitingBothView,
        questionMyOnlyView,
        questionPartnerOnlyView
    ]
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(contentContainerView)
        allContentViews.forEach { contentContainerView.addSubview($0) }
        contentContainerView.addSubview(questionBothView)
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
        
        questionBothView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.horizontalEdges.equalToSuperview().inset(26)
            $0.bottom.equalToSuperview().offset(-10)
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
            .distinctUntilChanged()
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
        
        reactor.state.map { $0.pokeSuccess }
            .filter({ $0 })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.showPokeAlert()
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
        
        let myAnswered = data.myInfo?.questionImageUrl != nil
        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        
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
            questionMyOnlyView.isHidden = false
            let name = data.myInfo?.name ?? ""
            let profile = data.myInfo?.profileImageUrl ?? ""
            let time = data.myInfo?.answeredAt ?? ""
            let image = data.myInfo?.questionImageUrl ?? ""
            
            questionMyOnlyView.configure(myImageURL: image, myName: name, myTime: time, myProfileURL: profile)
            
        case (true, true):
            questionBothView.isHidden = false
            
            questionBothView
                .configure(
                    question: data.question,
                    myImageURL: data.myInfo?.questionImageUrl ?? "",
                    myName: data.myInfo?.name ?? "",
                    myTime: data.myInfo?.answeredAt ?? "",
                    myProfile: data.myInfo?.profileImageUrl ?? "",
                    partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
                    partnerName: data.partnerInfo?.name ?? "",
                    partnerTime: data.partnerInfo?.answeredAt ?? "",
                    parterProfile: data.partnerInfo?.profileImageUrl ?? ""
                )
        }
    }
    
    private func hideAllContentViews() {
        allContentViews.forEach { $0.isHidden = true }
        questionBothView.isHidden = true
    }
    
    private func showPokeAlert() {
        CustomAlertViewController.show(
            on: self,
            title: "콕 찌르기 완료!",
            message: "상대방의 사진이 도착하면\n알림을 보내드릴게요.",
            confirmTitle: "확인"
        ) {}
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
        
        questionMyOnlyView.onNotifyTapped = { [weak self] in
            guard let self = self else { return }
        
            self.reactor?.action.onNext(.poke)
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
