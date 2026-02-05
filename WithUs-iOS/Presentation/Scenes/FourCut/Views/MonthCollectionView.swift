//
//  MonthCollectionView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/5/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import Foundation

protocol MonthCollectionViewDelegate: AnyObject {
    func monthCollectionView(_ view: MonthCollectionView, didSelectMonth month: Int)
}

class MonthCollectionView: UIView {
    
    weak var delegate: MonthCollectionViewDelegate?
    
    var selectedMonth: Int? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var monthData: [MonthItem] = MonthItem.allMonths() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, MonthItem>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRegistrations()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRegistrations() {
        cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, MonthItem> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            let isSelected = self.selectedMonth == item.month
            
            cell.contentConfiguration = UIHostingConfiguration {
                MonthCellView(item: item, isSelected: isSelected)
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
        let layout = UICollectionViewCompositionalLayout { _, layoutEnvironment in
            let containerWidth = layoutEnvironment.container.effectiveContentSize.width
            let itemWidth = containerWidth / 3
            let itemHeight: CGFloat = 52
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(itemWidth),
                heightDimension: .absolute(itemHeight)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(itemHeight)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 3)
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 0
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            return section
        }
        
        return layout
    }
}

extension MonthCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return monthData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = monthData[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
}

extension MonthCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let month = monthData[indexPath.item].month
        selectedMonth = month
        delegate?.monthCollectionView(self, didSelectMonth: month)
    }
}

// MARK: - Data Models

struct MonthItem {
    let month: Int
    let name: String
    
    // 1월부터 12월까지 생성
    static func allMonths() -> [MonthItem] {
        let monthNames = ["1월", "2월", "3월", "4월", "5월", "6월",
                          "7월", "8월", "9월", "10월", "11월", "12월"]
        
        return monthNames.enumerated().map { index, name in
            MonthItem(
                month: index + 1,
                name: name
            )
        }
    }
}
