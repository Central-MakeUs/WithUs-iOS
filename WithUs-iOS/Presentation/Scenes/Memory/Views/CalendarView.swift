//
//  CalendarView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/28/26.
//

//
//  CalendarView.swift
//  WithUs-iOS
//
//  Created on 1/28/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI

protocol CalendarViewDelegate: AnyObject {
    func calendarView(_ view: CalendarView, didSelectDate date: Date)
}

class CalendarView: UIView {
    
    weak var delegate: CalendarViewDelegate?
    
    private var photoDates: Set<String> = []
    private var monthsData: [MonthData] = []
    private var photoDataDict: [String: PhotoData] = [:]
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.init(hex: "#F0F0F0")
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    
    // Cell Registrations
    private var dayCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, CalendarDay>!
    private var monthHeaderRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewCell>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellRegistrations()
        setupUI()
        generateMonths()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellRegistrations() {
        // Day Cell
        dayCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, CalendarDay> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarDayCellView(day: item)
            }
            .margins(.all, 0)
            .background(Color.clear)
        }
        
        // Month Header
        monthHeaderRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }
            let monthData = self.monthsData[indexPath.section]
            
            supplementaryView.contentConfiguration = UIHostingConfiguration {
                CalendarMonthHeaderView(year: monthData.year, month: monthData.month)
            }
            .margins(.all, 0)
            .background(Color.white)
        }
    }
    
    private func setupUI() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in

            // 날짜 셀
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(42),
                heightDimension: .absolute(42)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(42)
            )
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitem: item,
                count: 7
            )
            group.interItemSpacing = .fixed(6)

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 6
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 6,
                leading: 16,
                bottom: 18,
                trailing: 16
            )

            // 🔥 header 하나만
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(72) // 36 + 36
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )

            section.boundarySupplementaryItems = [header]
            
            let background = NSCollectionLayoutDecorationItem.background(
                        elementKind: "section-background"
                    )
                    background.contentInsets = NSDirectionalEdgeInsets(
                        top: 0,
                        leading: 0,
                        bottom: 0,
                        trailing: 0
                    )

                    section.decorationItems = [background]
            return section
        }
        
        layout.register(
            CalendarSectionBackgroundView.self,
            forDecorationViewOfKind: "section-background"
        )
        
        return layout
    }

    
    private func generateMonths() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // 현재 월부터 과거 12개월까지 생성 (최신이 위에)
        //TODO: 서버에서 가장 오래된 날짜와 최근 사진 날짜를 받아서 사이에 개월수를 받아서 아래에 넣어준다.
        monthsData = []
        
        for i in 0..<12 {
            if let monthDate = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                let year = calendar.component(.year, from: monthDate)
                let month = calendar.component(.month, from: monthDate)
                let days = generateDaysForMonth(year: year, month: month)
                monthsData.append(MonthData(year: year, month: month, days: days))
            }
        }
        
        collectionView.reloadData()
    }
    
    private func generateDaysForMonth(year: Int, month: Int) -> [CalendarDay] {
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let monthStart = calendar.date(from: components),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart) else {
            return []
        }
        
        // 첫날의 요일 (일요일: 1, 토요일: 7)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        
        var days: [CalendarDay] = []
        
        // 이전 월의 빈 칸
        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: nil, day: 0, hasPhoto: false, thumbnailURL: nil))
        }
        
        // 현재 월의 날짜들
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let dateString = dateFormatter.string(from: date)
                let photoData = photoDataDict[dateString] // 서버에서 받은 데이터
                let hasPhoto = photoData != nil
                let thumbnailURL = photoData?.thumbnailURL
                
                days.append(CalendarDay(
                    date: date,
                    day: day,
                    hasPhoto: hasPhoto,
                    thumbnailURL: thumbnailURL
                ))
            }
        }
        
        return days
    }
    
    func updatePhotoData(_ data: [String: PhotoData]) {
        self.photoDataDict = data
        
        // 모든 월 데이터 다시 생성
        for i in 0..<monthsData.count {
            let year = monthsData[i].year
            let month = monthsData[i].month
            monthsData[i].days = generateDaysForMonth(year: year, month: month)
        }
        
        collectionView.reloadData()
    }
}

extension CalendarView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return monthsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsData[section].days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let day = monthsData[indexPath.section].days[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: dayCellRegistration,
            for: indexPath,
            item: day
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: monthHeaderRegistration,
                for: indexPath
            )
        }
        
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate
extension CalendarView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let day = monthsData[indexPath.section].days[indexPath.item]
        if day.hasPhoto, let date = day.date {
            delegate?.calendarView(self, didSelectDate: date)
        }
    }
}

// MARK: - Data Models
struct MonthData {
    let year: Int
    let month: Int
    var days: [CalendarDay]
}

struct CalendarDay {
    let date: Date?
    let day: Int
    let hasPhoto: Bool
    let thumbnailURL: String? // 추가
}

struct PhotoData {
    let thumbnailURL: String
    let photoCount: Int?
}

final class CalendarSectionBackgroundView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 16
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
