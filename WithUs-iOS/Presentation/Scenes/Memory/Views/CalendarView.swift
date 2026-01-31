//
//  CalendarView.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/28/26.
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
    
    private var monthsData: [MonthData] = []
    private var photoDataDict: [String: PhotoData] = [:]
    
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor(hex: "#F0F0F0")
        cv.delegate = self
        cv.dataSource = self
        cv.showsVerticalScrollIndicator = true
        return cv
    }()
    
    private var monthCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, MonthData>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellRegistration()
        setupUI()
        generateMonths()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellRegistration() {
        monthCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, MonthData> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            cell.contentConfiguration = UIHostingConfiguration {
                CalendarMonthCellView(monthData: item) { date in
                    self.delegate?.calendarView(self, didSelectDate: date)
                }
            }
            .margins(.all, 0)
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
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(373)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(373)
            )
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 18
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 16,
                bottom: 12,
                trailing: 16
            )
            
            return section
        }
        
        return layout
    }
    
    /// 서버에서 첫 사진 날짜 ~ 마지막 사진 날짜를 받아서 그 사이의 모든 월 생성
    func generateMonthsFromRange(firstPhotoDate: Date, lastPhotoDate: Date) {
        let calendar = Calendar.current
        monthsData = []
        
        let firstComponents = calendar.dateComponents([.year, .month], from: firstPhotoDate)
        guard let firstYear = firstComponents.year,
              let firstMonth = firstComponents.month else { return }
        
        let lastComponents = calendar.dateComponents([.year, .month], from: lastPhotoDate)
        guard let lastYear = lastComponents.year,
              let lastMonth = lastComponents.month else { return }
        
        var components = DateComponents()
        components.year = firstYear
        components.month = firstMonth
        components.day = 1
        
        guard let currentDate = calendar.date(from: components) else { return }
        
        var endComponents = DateComponents()
        endComponents.year = lastYear
        endComponents.month = lastMonth
        endComponents.day = 1
        guard let endDate = calendar.date(from: endComponents) else { return }
        
        var tempMonths: [MonthData] = []
        var iterDate = endDate
        
        while iterDate >= currentDate {
            let year = calendar.component(.year, from: iterDate)
            let month = calendar.component(.month, from: iterDate)
            let days = generateDaysForMonth(year: year, month: month)
            
            tempMonths.append(MonthData(year: year, month: month, days: days))
            
            guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: iterDate) else { break }
            iterDate = prevMonth
        }
        
        monthsData = tempMonths
        collectionView.reloadData()
    }
    
    /// 임시: 현재부터 과거 12개월 생성
    private func generateMonths() {
        let calendar = Calendar.current
        let currentDate = Date()
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
    
    /// 특정 년/월의 날짜들 생성 (빈 칸 포함)
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
        
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        
        var days: [CalendarDay] = []
        
        // 이전 월의 빈 칸
        for _ in 1..<firstWeekday {
            days.append(CalendarDay(date: nil, day: 0, hasPhoto: false, photoData: nil))
        }
        
        // 현재 월의 날짜들
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                let dateString = dateFormatter.string(from: date)
                let photoDictData = photoDataDict[dateString]
                let hasPhoto = photoDictData != nil
                
                days.append(CalendarDay(
                    date: date,
                    day: day,
                    hasPhoto: hasPhoto,
                    photoData: photoDictData?.photoData
                ))
            }
        }
        
        return days
    }
    
    func updatePhotoData(_ data: [String: PhotoData]) {
        self.photoDataDict = data
        
        for i in 0..<monthsData.count {
            let year = monthsData[i].year
            let month = monthsData[i].month
            monthsData[i].days = generateDaysForMonth(year: year, month: month)
        }
        
        collectionView.reloadData()
    }
}

extension CalendarView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthsData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let monthData = monthsData[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: monthCellRegistration,
            for: indexPath,
            item: monthData
        )
    }
}

extension CalendarView: UICollectionViewDelegate {}
