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
    func calendarView(_ view: CalendarView, didSelectDate date: String)
}

class CalendarView: UIView {
    weak var delegate: CalendarViewDelegate?
    
    // 데이터 요청 콜백 - Reactor와 연결
    var onMonthVisible: ((Int, Int) -> Void)?
    
    // 로딩된 월 추적
    private var loadedMonths: Set<String> = []
    
    // 월별 데이터
    private var monthsData: [ArchiveCalendarResponse] = []
    
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
    
    private var monthCellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, ArchiveCalendarResponse>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCellRegistration()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCellRegistration() {
        monthCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, ArchiveCalendarResponse> {
            [weak self] cell, _, item in
            guard let self else { return }
            
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
    
    func setupInitialMonths(from joinDate: Date) {
        let calendar = Calendar.current
        let endDate = Date()
        let startComponents = calendar.dateComponents([.year, .month], from: joinDate)
        guard let startLimit = calendar.date(from: startComponents) else { return }
        var months: [ArchiveCalendarResponse] = []
        let endComponents = calendar.dateComponents([.year, .month], from: endDate)
        var currentDate = calendar.date(from: endComponents)!
        
        while currentDate >= startLimit {
            let year = calendar.component(.year, from: currentDate)
            let month = calendar.component(.month, from: currentDate)
            
            months.append(
                ArchiveCalendarResponse(
                    year: year,
                    month: month,
                    days: generateEmptyDays(year: year, month: month)
                )
            )
            
            guard let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
                break
            }
            currentDate = prevMonth
        }
        self.monthsData = months
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func applyCalendarResponse(_ response: ArchiveCalendarResponse) {
        guard let index = monthsData.firstIndex(
            where: { $0.year == response.year && $0.month == response.month }
        ) else {
            return
        }
        
        let dayMap = Dictionary(
            uniqueKeysWithValues: response.days.map { ($0.date, $0) }
        )
        let updatedDays = monthsData[index].days.map { day -> ArchiveDay in
            guard !day.date.isEmpty else {
                return day
            }
            
            if let serverDay = dayMap[day.date] {
                return serverDay
            } else {
                return day
            }
        }
        
        let photoDaysCount = updatedDays.filter { $0.hasPhoto }.count
        
        monthsData[index] = ArchiveCalendarResponse(
            year: response.year,
            month: response.month,
            days: updatedDays
        )
        
        loadedMonths.insert("\(response.year)-\(response.month)")
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        }
    }
    
    
    private func generateEmptyDays(year: Int, month: Int) -> [ArchiveDay] {
        let calendar = Calendar.current
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        
        guard let startDate = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startDate)
        else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: startDate)
        var days: [ArchiveDay] = []
        
        for _ in 1..<firstWeekday {
            days.append(
                ArchiveDay(date: "", meImageThumbnailUrl: nil, partnerImageThumbnailUrl: nil)
            )
        }
        
        // 실제 날짜들
        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startDate) else {
                continue
            }
            days.append(
                ArchiveDay(
                    date: dateFormatter.string(from: date),
                    meImageThumbnailUrl: nil,
                    partnerImageThumbnailUrl: nil
                )
            )
        }
        
        return days
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

extension CalendarView: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        let month = monthsData[indexPath.item]
        let key = "\(month.year)-\(month.month)"
        
        guard !loadedMonths.contains(key) else { return }
        
        onMonthVisible?(month.year, month.month)
    }
}
