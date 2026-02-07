//
//  MemoryCollectionView.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/5/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import Foundation

protocol MemoryCollectionViewDelegate: AnyObject {
    func memoryCollectionView(_ view: MemoryCollectionView, didSelectItemAt index: Int)
}

class MemoryCollectionView: UIView {
    weak var delegate: MemoryCollectionViewDelegate?
    
    var memoryData: [WeekMemorySummary] = [] {
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
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, WeekMemorySummary>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRegistrations()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRegistrations() {
        cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, WeekMemorySummary> {
            cell, _, item in
            
            cell.contentConfiguration = UIHostingConfiguration {
                MemoryFullCellView(item: item)
            }
            .margins(.all, 0)
            cell.contentView.clipsToBounds = true
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
            let containerHeight = layoutEnvironment.container.effectiveContentSize.height
            let dateRaneHeight: CGFloat = 36
            let cellWidth = containerHeight / 1.6 - dateRaneHeight
            
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .absolute(cellWidth),
                heightDimension: .absolute(containerHeight)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 8
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
            section.orthogonalScrollingBehavior = .none
            
            return section
        }
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        layout.configuration = config
        
        return layout
    }
}

extension MemoryCollectionView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memoryData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = memoryData[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
}

extension MemoryCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.memoryCollectionView(self, didSelectItemAt: indexPath.item)
    }
}

