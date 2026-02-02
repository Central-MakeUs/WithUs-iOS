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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCalendarData()
    }
    
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
                .subscribe(onNext: { error in
                    print("❌ Archive 에러: \(error)")
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
    
    private func loadCalendarData() {
        let dummyImageURL = "https://picsum.photos/seed/"
        
        let photoData: [String: PhotoData] = [
            // 1월 테스트
            "2026-01-01": PhotoData(
                thumbnailURL: dummyImageURL + "cal1/200/200",
                photoCount: 3,
                photoData: SinglePhotoData(date: "2026.01.01", question: "새해 첫날의 기억은?", imageURL: dummyImageURL + "cal1/400/640", name: "JPG", time: "AM 10:00", kind: .combined)
            ),
            "2026-01-05": PhotoData(
                thumbnailURL: dummyImageURL + "cal2/200/200",
                photoCount: 1,
                photoData: SinglePhotoData(date: "2026.01.05", question: "", imageURL: dummyImageURL + "cal2/400/640", name: "JPG", time: "PM 03:20", kind: .single)
            ),
            "2026-01-12": PhotoData(
                thumbnailURL: dummyImageURL + "cal3/200/200",
                photoCount: 2,
                photoData: SinglePhotoData(date: "2026.01.12", question: "지금까지 받은 사진 중\n가장 이쁘게 담긴 제페토의 사진은?", imageURL: dummyImageURL + "cal3/400/640", name: "JPG", time: "PM 02:35", kind: .combined)
            ),
            "2026-01-15": PhotoData(
                thumbnailURL: dummyImageURL + "cal4/200/200",
                photoCount: 5,
                photoData: SinglePhotoData(date: "2026.01.15", question: "", imageURL: dummyImageURL + "cal4/400/640", name: "JPG", time: "AM 09:15", kind: .single)
            ),
            "2026-01-20": PhotoData(
                thumbnailURL: dummyImageURL + "cal5/200/200",
                photoCount: 1,
                photoData: SinglePhotoData(date: "2026.01.20", question: "이번주 가장 좋은 날은?", imageURL: dummyImageURL + "cal5/400/640", name: "JPG", time: "PM 06:00", kind: .combined)
            ),
            "2026-01-25": PhotoData(
                thumbnailURL: dummyImageURL + "cal6/200/200",
                photoCount: 4,
                photoData: SinglePhotoData(date: "2026.01.25", question: "", imageURL: dummyImageURL + "cal6/400/640", name: "JPG", time: "PM 01:45", kind: .single)
            ),
            
            // 12월 테스트
            "2025-12-01": PhotoData(
                thumbnailURL: dummyImageURL + "cal7/200/200",
                photoCount: 3,
                photoData: SinglePhotoData(date: "2025.12.01", question: "12월의 첫날은?", imageURL: dummyImageURL + "cal7/400/640", name: "JPG", time: "AM 11:30", kind: .combined)
            ),
            "2025-12-09": PhotoData(
                thumbnailURL: dummyImageURL + "cal8/200/200",
                photoCount: 1,
                photoData: SinglePhotoData(date: "2025.12.09", question: "", imageURL: dummyImageURL + "cal8/400/640", name: "JPG", time: "PM 04:10", kind: .single)
            ),
            "2025-12-15": PhotoData(
                thumbnailURL: dummyImageURL + "cal9/200/200",
                photoCount: 2,
                photoData: SinglePhotoData(date: "2025.12.15", question: "크리스마스 준비 중?", imageURL: dummyImageURL + "cal9/400/640", name: "JPG", time: "PM 05:50", kind: .combined)
            ),
            "2025-12-25": PhotoData(
                thumbnailURL: dummyImageURL + "cal10/200/200",
                photoCount: 1,
                photoData: SinglePhotoData(date: "2025.12.25", question: "", imageURL: dummyImageURL + "cal10/400/640", name: "JPG", time: "AM 08:00", kind: .single)
            ),
        ]
        
        calendarView.updatePhotoData(photoData)
    }
}

extension ArchiveViewController: CustomSegmentedControlDelegate {
    func segmentedControl(_ control: CustomSegmentedControl, didSelectSegmentAt index: Int) {
        reactor?.action.onNext(.selectTab(index))
    }
}

extension ArchiveViewController: CalendarViewDelegate {
    func calendarView(_ view: CalendarView, didSelectDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        print("선택된 날짜: \(dateString)")
        
        // 테스트용 데이터
        let testData = SinglePhotoData(
            date: "2025.12.09",
            question: "지금까지 받은 사진 중\n가장 이쁘게 담긴 제페토의 사진은?",
            imageURL: "https://1x.com/quickimg/4bf2f73146695b7e313936b92dff691b.jpg",
            name: "JPG",
            time: "PM 02:35", kind: .combined
        )
        
//        let vc = ArchiveDetailViewController(photoData: testData)
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArchiveViewController: QuestionListViewDelegate {
    func didSelectQuestion(_ question: Question) {
        print("선택된 question: \(question)")
        
        // 테스트용 데이터
        let testData = SinglePhotoData(
            date: "2025.12.09",
            question: question.text,
            imageURL: "https://1x.com/quickimg/4bf2f73146695b7e313936b92dff691b.jpg",
            name: "JPG",
            time: "PM 02:35", kind: .single
        )
        
//        let vc = ArchiveDetailViewController(photoData: testData)
//        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArchiveViewController: ArchiveRecentViewDelegate {
    func didSelectPhoto(_ photo: ArchivePhotoViewModel) {
        // 내 사진이 있으면 내 사진, 없으면 상대방 사진
//        let imageUrl = photo.myImageUrl ?? photo.partnerImageUrl
//        
//        let testData = SinglePhotoData(
//            date: photo.date,
//            question: photo.archiveType == "QUESTION" ? "질문 내용" : nil,  // TODO: 실제 질문 텍스트는 별도 API 필요
//            imageURL: imageUrl,
//            name: "",  // TODO: 이름 정보 필요시 API 추가
//            time: "",  // TODO: 시간 정보 필요시 API 추가
//            kind: photo.kind == .combined ? .combined : .single
//        )
//        
//        let vc = ArchiveDetailViewController(photoData: testData)
//        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didScrollToBottom() {
        reactor?.action.onNext(.loadMoreRecent)
    }
}
