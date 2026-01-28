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
    
    private let calendarView = CalendarView().then {
        $0.isHidden = true
    }
    
    private let questionView = QuestionListView().then {
        $0.isHidden = true
        $0.addShadow()
    }
    
    private var photos: [ArchivePhoto] = []
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, ArchivePhoto>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellRegistration()
        loadMockData()
        loadCalendarData()
    }
    
    private func setupCellRegistration() {
        cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ArchivePhoto> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                ArchivePhotoCellView(photo: item)
            }
            .margins(.all, 0)
            .background(Color.clear)
        }
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
        photos = [
            ArchivePhoto(id: "1", date: "1월 12일", imageURL: nil, hugCount: "37 Hug × 21 Hug"),
            ArchivePhoto(id: "2", date: "1월 9일", imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "3", date: "1월 9일", imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "4", date: "12월 12일", imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "6", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "7", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "8", date: "11월 31일", imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "9", date: nil, imageURL: nil, hugCount: nil),
            ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil),ArchivePhoto(id: "5", date: "12월 9일", imageURL: nil, hugCount: nil)
        ]
    }
    
    private func loadCalendarData() {
        let dummyImages = [
            "https://picsum.photos/200/200?random=1",
            "https://picsum.photos/200/200?random=2",
            "https://picsum.photos/200/200?random=3",
            "https://picsum.photos/200/200?random=4",
            "https://picsum.photos/200/200?random=5"
        ]
        
        let photoData: [String: PhotoData] = [
            // 1월 테스트
            "2026-01-01": PhotoData(thumbnailURL: dummyImages[0], photoCount: 3),
            "2026-01-05": PhotoData(thumbnailURL: dummyImages[1], photoCount: 1),
            "2026-01-12": PhotoData(thumbnailURL: dummyImages[2], photoCount: 2),
            "2026-01-15": PhotoData(thumbnailURL: dummyImages[3], photoCount: 5),
            "2026-01-20": PhotoData(thumbnailURL: dummyImages[4], photoCount: 1),
            "2026-01-25": PhotoData(thumbnailURL: dummyImages[0], photoCount: 4),
            
            // 12월 테스트
            "2025-12-01": PhotoData(thumbnailURL: dummyImages[1], photoCount: 3),
            "2025-12-09": PhotoData(thumbnailURL: dummyImages[2], photoCount: 1),
            "2025-12-15": PhotoData(thumbnailURL: dummyImages[3], photoCount: 2),
            "2025-12-25": PhotoData(thumbnailURL: dummyImages[4], photoCount: 1),
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

extension ArchiveViewController: CalendarViewDelegate {
    func calendarView(_ view: CalendarView, didSelectDate date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        print("선택된 날짜: \(dateString)")
        // TODO: 해당 날짜의 사진들을 보여주는 화면으로 이동
        // coordinator?.showPhotosForDate(dateString)
    }
}

extension ArchiveViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = photos[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: photo
        )
    }
}

extension ArchiveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = photos[indexPath.item]
        print("선택된 사진: \(photo.id)")
        // TODO: 사진 상세 화면으로 이동
    }
}
