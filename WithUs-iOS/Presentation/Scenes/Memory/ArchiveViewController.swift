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
    
    private let emptyView = EmptyArchiveView().then {
        $0.isHidden = true
    }
    
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
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, ArchivePhoto>!
    
    private let deleteContainer = UIView().then {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 9
    }
    
    private let deleteButton = UIButton().then {
        $0.setTitle("삭제하기", for: .normal)
        $0.setTitleColor(UIColor.gray50, for: .normal)
        $0.backgroundColor = UIColor.gray300
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("돌아가기", for: .normal)
        $0.setTitleColor(UIColor.init(hex: "#565962"), for: .normal)
        $0.titleLabel?.font = UIFont.pretendard14Regular
    }
    
    override func setupUI() {
        super.setupUI()
        segmentedControl.delegate = self
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        view.addSubview(emptyView)
        view.addSubview(deleteContainer)
        
        containerView.addSubview(recentView)
        containerView.addSubview(calendarView)
        containerView.addSubview(questionView)
        
        deleteContainer.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(deleteButton)
        buttonStackView.addArrangedSubview(cancelButton)
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
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
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
        
        deleteContainer.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(150)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(9)
        }
        
        deleteButton.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        cancelButton.snp.makeConstraints {
            $0.height.equalTo(41)
        }
    }
    
    override func setNavigation() {
        let attributedText = NSAttributedString(
            string: "보관",
            attributes: [.foregroundColor: UIColor.gray900, .font: UIFont.pretendard24Bold]
        )
        setLeftBarButton(attributedTitle: attributedText)
        
        updateNavigationBar(for: 0)
    }
    
    override func setupActions() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func navigationBarTapped() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let deleteAllAction = UIAlertAction(title: "전체 삭제", style: .default) { [weak self] _ in
            self?.showDeleteAllConfirmation()
        }
        deleteAllAction.setValue(UIColor.redWarning, forKey: "titleTextColor")

        let deleteSelectedAction = UIAlertAction(title: "선택 삭제", style: .default) { [weak self] _ in
            self?.enableSelectionMode()
        }

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)

        alert.addAction(deleteAllAction)
        alert.addAction(deleteSelectedAction)
        alert.addAction(cancelAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func deleteButtonTapped() {
        deleteSelectedPhotos()
    }
    
    @objc private func cancelButtonTapped() {
        cancelSelectionMode()
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
                ToastView.show(message: error)
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
        
        reactor.state.map { $0.isAllDataEmpty }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.showEmptyState()
                } else {
                    self?.hideEmptyState()
                }
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isInitialLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                isLoading ? owner.showLoading() : owner.hideLoading()
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.loadingActions.contains(.loadMoreRecent) }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                isLoading ? owner.showLoading() : owner.hideLoading()
            }
            .disposed(by: disposeBag)

        reactor.state.map { $0.loadingActions.contains(.loadMoreQuestions) }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, isLoading in
                isLoading ? owner.showLoading() : owner.hideLoading()
            }
            .disposed(by: disposeBag)
    }
    
    private func showEmptyState() {
        emptyView.isHidden = false
        segmentedControl.isHidden = true
        containerView.isHidden = true
        navigationItem.rightBarButtonItem = nil
    }
    
    private func hideEmptyState() {
        emptyView.isHidden = true
        segmentedControl.isHidden = false
        containerView.isHidden = false
        updateNavigationBar(for: reactor?.currentState.selectedTab ?? 0)
    }
    
    private func updateNavigationBar(for tabIndex: Int) {
        if tabIndex == 0 {
            let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
            let image = UIImage(systemName: "ellipsis", withConfiguration: config)
            setRightBarButton(image: image, action: #selector(navigationBarTapped), tintColor: .black)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    private func enableSelectionMode() {
        recentView.isSelectionMode = true
        deleteContainer.isHidden = false
        updateDeleteButton(selectedCount: 0)
        self.tabBarController?.tabBar.isHidden = true
        navigationItem.rightBarButtonItem = nil
    }
    
    private func cancelSelectionMode() {
        recentView.isSelectionMode = false
        deleteContainer.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        
        updateNavigationBar(for: 0)
    }
    
    private func showView(at index: Int) {
        if index != 0 && !deleteContainer.isHidden {
            cancelSelectionMode()
        }
        
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
        
        // 탭 변경 시 네비게이션 바 업데이트
        updateNavigationBar(for: index)
    }
    
    private func updateDeleteButton(selectedCount: Int) {
        if selectedCount > 0 {
            deleteButton.isEnabled = true
            deleteButton.setTitle("\(selectedCount)장의 사진 삭제하기", for: .normal)
            deleteButton.setTitleColor(.white, for: .normal)
            deleteButton.backgroundColor = .black
        } else {
            deleteButton.isEnabled = false
            deleteButton.setTitle("삭제하기", for: .normal)
            deleteButton.setTitleColor(UIColor.gray50, for: .normal)
            deleteButton.backgroundColor = UIColor.gray300
        }
    }
    
    private func deleteSelectedPhotos() {
        let selectedPhotos = recentView.getSelectedPhotos()
        
        if selectedPhotos.isEmpty {
            let alert = UIAlertController(title: "알림", message: "삭제할 사진을 선택해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let alert = UIAlertController(
            title: "사진 삭제",
            message: "\(selectedPhotos.count)장의 사진을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            // TODO: Reactor에 삭제 액션 전달
            print("삭제된 사진 개수: \(selectedPhotos.count)")
            
            self?.cancelSelectionMode()
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAllConfirmation() {
        let alert = UIAlertController(
            title: "전체 삭제",
            message: "모든 사진을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            // TODO: Reactor에 전체 삭제 액션 전달
            print("전체 삭제 실행")
        })
        
        present(alert, animated: true)
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

extension ArchiveViewController: ArchiveRecentViewDelegate {
    func didSelectPhoto(_ photo: ArchivePhotoViewModel) {
        reactor?.action.onNext(.fetchPhotoDetail(date: photo.date, targetId: photo.id, targetType: photo.archiveType))
    }
    
    func didScrollToBottomRecent() {
        reactor?.action.onNext(.loadMoreRecent)
    }
    
    func didChangeSelection(count: Int) {
        updateDeleteButton(selectedCount: count)
    }
}
