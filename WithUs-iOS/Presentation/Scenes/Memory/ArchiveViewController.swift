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

class ArchiveViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    
    private let segmentedControl = CustomSegmentedControl(segments: ["최신순", "캘린더", "질문"])
    
    private let containerView = UIView()
    
    private lazy var recentCollectionView: UICollectionView = {
        let layout = createRecentLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
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
        setupCellRegistration()
        loadMockData()
        loadCalendarData()
    }
    
    private func setupCellRegistration() {
        recentCollectionView.register(
            CombinedImageCell.self,
            forCellWithReuseIdentifier: CombinedImageCell.reuseId
        )
        recentCollectionView.register(
            BlurredDetailCell.self,
            forCellWithReuseIdentifier: BlurredDetailCell.reuseId
        )
    }
    
    override func setupUI() {
        super.setupUI()
        segmentedControl.delegate = self
        
        view.addSubview(segmentedControl)
        view.addSubview(containerView)
        
        containerView.addSubview(recentCollectionView)
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
            $0.top.equalTo(segmentedControl.snp.bottom)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        recentCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        calendarView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
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
    
    private func createRecentLayout() -> UICollectionViewLayout {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalSpacing: CGFloat = 3
        let totalHorizontalSpacing = horizontalSpacing * 2
        let itemWidth = (screenWidth - totalHorizontalSpacing) / 3
        let itemHeight = itemWidth * 1.6
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(itemWidth),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(horizontalSpacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private func loadMockData() {
            let dummyImageURL = "https://picsum.photos/400/640?random="
            
            photos = [
                SinglePhotoData(
                    date: "2026.01.12",
                    question: "지금까지 받은 사진 중\n가장 이쁘게 담긴 제페토의 사진은?",
                    imageURL: dummyImageURL + "1",
                    name: "JPG",
                    time: "PM 02:35",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2026.01.09",
                    question: "오늘 가장 행복한 순간은?",
                    imageURL: dummyImageURL + "2",
                    name: "JPG",
                    time: "AM 10:12",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2026.01.09",
                    question: "",
                    imageURL: dummyImageURL + "3",
                    name: "JPG",
                    time: "PM 06:45",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.12.12",
                    question: "금주의 가장 좋은 날은?",
                    imageURL: dummyImageURL + "4",
                    name: "JPG",
                    time: "PM 01:20",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.12.09",
                    question: "",
                    imageURL: dummyImageURL + "5",
                    name: "JPG",
                    time: "AM 09:00",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.12.09",
                    question: "오늘의 날씨와 같은 감정은?",
                    imageURL: dummyImageURL + "6",
                    name: "JPG",
                    time: "PM 03:10",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.12.01",
                    question: "",
                    imageURL: dummyImageURL + "7",
                    name: "JPG",
                    time: "PM 05:55",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.11.28",
                    question: "이번 달 가장 소중한 기억은?",
                    imageURL: dummyImageURL + "8",
                    name: "JPG",
                    time: "AM 11:30",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.11.28",
                    question: "",
                    imageURL: dummyImageURL + "9",
                    name: "JPG",
                    time: "PM 04:22",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.11.20",
                    question: "",
                    imageURL: dummyImageURL + "10",
                    name: "JPG",
                    time: "AM 08:15",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.11.15",
                    question: "주말에 가장 즐거운 활동은?",
                    imageURL: dummyImageURL + "11",
                    name: "JPG",
                    time: "PM 02:00",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.11.15",
                    question: "",
                    imageURL: dummyImageURL + "12",
                    name: "JPG",
                    time: "PM 07:40",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.11.10",
                    question: "",
                    imageURL: dummyImageURL + "13",
                    name: "JPG",
                    time: "AM 10:50",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.11.05",
                    question: "가장 좋아하는 색깔의 날은?",
                    imageURL: dummyImageURL + "14",
                    name: "JPG",
                    time: "PM 12:00",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.11.01",
                    question: "",
                    imageURL: dummyImageURL + "15",
                    name: "JPG",
                    time: "AM 07:30",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.10.28",
                    question: "이번 달 마지막 날의 기억은?",
                    imageURL: dummyImageURL + "16",
                    name: "JPG",
                    time: "PM 09:10",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.10.25",
                    question: "",
                    imageURL: dummyImageURL + "17",
                    name: "JPG",
                    time: "PM 03:45",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.10.20",
                    question: "",
                    imageURL: dummyImageURL + "18",
                    name: "JPG",
                    time: "AM 11:00",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.10.15",
                    question: "요즘 가장 많이 웃은 날은?",
                    imageURL: dummyImageURL + "19",
                    name: "JPG",
                    time: "PM 01:55",
                    kind: .combined
                ),
                SinglePhotoData(
                    date: "2025.10.10",
                    question: "",
                    imageURL: dummyImageURL + "20",
                    name: "JPG",
                    time: "AM 09:30",
                    kind: .single
                ),
                SinglePhotoData(
                    date: "2025.10.05",
                    question: "",
                    imageURL: dummyImageURL + "21",
                    name: "JPG",
                    time: "PM 06:20",
                    kind: .single
                )
            ]
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
        recentCollectionView.isHidden = true
        calendarView.isHidden = true
        questionView.isHidden = true
        
        switch index {
        case 0: // 최신순
            recentCollectionView.isHidden = false
        case 1: // 캘린더
            calendarView.isHidden = false
        case 2: // 질문
            questionView.isHidden = false
        default:
            break
        }
    }
}

//extension ArchiveViewController: CalendarViewDelegate {
//    func calendarView(_ view: CalendarView, didSelectDate date: Date) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
//        let dateString = dateFormatter.string(from: date)
//        
//        print("선택된 날짜: \(dateString)")
//        // TODO: 해당 날짜의 사진들을 보여주는 화면으로 이동
//        // coordinator?.showPhotosForDate(dateString)
//    }
//}

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
        
        let vc = ArchiveDetailViewController(photoData: testData)
        navigationController?.pushViewController(vc, animated: true)
    }
}

//extension ArchiveViewController: QuestionListViewDelegate {
//    func didSelectQuestion(_ question: Question) {
//        print("선택된 question: \(question)")
//    }
//}

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
        
        let vc = ArchiveDetailViewController(photoData: testData)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArchiveViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.item]
        
        switch photo.kind {
        case .combined:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CombinedImageCell.reuseId,
                for: indexPath
            ) as! CombinedImageCell
            cell.configure(with: photo)
            return cell
            
        case .single:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: BlurredDetailCell.reuseId,
                for: indexPath
            ) as! BlurredDetailCell
            cell.configure(with: photo)
            return cell
        }
    }
}
//
//extension ArchiveViewController: UICollectionViewDelegate {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let photo = photos[indexPath.item]
//        print("선택된 사진: \(photo.id)")
//        // TODO: 사진 상세 화면으로 이동
//    }
//}

extension ArchiveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 테스트용 데이터
        let testData = SinglePhotoData(
            date: "2025.12.09",
            question: "지금까지 받은 사진 중\n가장 이쁘게 담긴 제페토의 사진은?",
            imageURL: "https://1x.com/quickimg/4bf2f73146695b7e313936b92dff691b.jpg",
            name: "JPG",
            time: "PM 02:35", kind: .combined
        )
        
        let vc = ArchiveDetailViewController(photoData: testData)
        navigationController?.pushViewController(vc, animated: true)
    }
}
