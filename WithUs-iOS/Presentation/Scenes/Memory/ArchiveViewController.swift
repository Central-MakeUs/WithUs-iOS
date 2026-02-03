//
//  ArchiveViewController.swift
//  WithUs-iOS
//
//  Created on 1/27/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import ReactorKit
import RxSwift
import RxCocoa

class ArchiveViewController: BaseViewController, ReactorKit.View {
    weak var coordinator: ArchiveCoordinator?
    var disposeBag = DisposeBag()
    
    private let segmentedControl = CustomSegmentedControl(segments: ["최신순", "캘린더", "질문"])
    
    private let containerView = UIView()
    
    private lazy var recentView = ArchiveRecentView().then {
        $0.delegate = self
    }
    
    private lazy var calendarView = CalendarView().then {
        $0.isHidden = true
        $0.delegate = self
    }
    
    private lazy var questionView = QuestionListView().then {
        $0.isHidden = true
        $0.delegate = self
    }
    
    private var photos: [SinglePhotoData] = []
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, ArchivePhoto>!
    
    override func setupUI() {
        super.setupUI()
        segmentedControl.delegate = self
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        containerView.addSubview(recentView)
        containerView.addSubview(calendarView)
        containerView.addSubview(questionView)
    }
    
    override func setupConstraints() {
        segmentedControl.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.height.equalTo(45)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControl.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        recentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        questionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setNavigation() {
        let attributedText = NSAttributedString(
            string: "보관",
            attributes: [.foregroundColor: UIColor.gray900, .font: UIFont.pretendard24Bold]
        )
        setLeftBarButton(attributedTitle: attributedText)
        
        let moreButton = UIButton(type: .system)
        moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.tintColor = .gray900
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
    }
    
    func bind(reactor: ArchiveReactor) {
        rx.viewDidLoad
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedTab }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] index in
                self?.showView(at: index)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.recentPhotos }
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] photos in
                self?.recentView.updatePhotos(photos)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { (error: String) in
                print("❌ Archive 에러: \(error)")
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.calendarDataList }
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] dataList in
                if let lastData = dataList.last {
                    self?.calendarView.applyCalendarResponse(lastData)
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.joinDate }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (joinDate: Date?) in
                self?.calendarView.setupInitialMonths(from: joinDate)
            })
            .disposed(by: disposeBag)
        
        calendarView.onMonthVisible = { [weak reactor] year, month in
            reactor?.action.onNext(.loadCalendarMonth(year: year, month: month))
        }
        
        reactor.state
            .map { $0.questions }
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] questions in
                self?.questionView.updateQuestions(questions)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.questionDetail }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] detail in
                self?.coordinator?.showQuestionDetail(.question(detail))
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.photoDetail }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] detail in
                self?.coordinator?.showQuestionDetail(.photo(detail))
            })
            .disposed(by: disposeBag)
    }
    
    private func showView(at index: Int) {
        recentView.isHidden = true
        calendarView.isHidden = true
        questionView.isHidden = true
        
        switch index {
        case 0:
            recentView.isHidden = false
        case 1:
            calendarView.isHidden = false
        case 2:
            questionView.isHidden = false
        default:
            break
        }
    }
}

extension ArchiveViewController: CustomSegmentedControlDelegate {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectSegmentAt index: Int) {
        reactor?.action.onNext(.selectTab(index))
    }
}

extension ArchiveViewController: CalendarViewDelegate {
    func calendarView(_ view: CalendarView, didSelectDate date: String) {
        reactor?.action.onNext(.fetchPhotoDetail(date: date, targetId: nil, targetType: nil))
    }
}

extension ArchiveViewController: QuestionListViewDelegate {
    func didSelectQuestion(_ question: ArchiveQuestionItem) {
        
        reactor?.action.onNext(.fetchQuestionDetail(coupleQuestionId: question.coupleQuestionId))
    }
    
    func didScrollToBottomQuestion() {
        reactor?.action.onNext(.loadMoreQuestions)
    }
}

// MARK: - ArchiveRecentViewDelegate

extension ArchiveViewController: ArchiveRecentViewDelegate {
    func didSelectPhoto(_ photo: ArchivePhotoViewModel) {
        reactor?.action.onNext(.fetchPhotoDetail(date: photo.date, targetId: photo.id, targetType: photo.archiveType))
    }
    
    func didScrollToBottomRecent() {
        reactor?.action.onNext(.loadMoreRecent)
    }
}
