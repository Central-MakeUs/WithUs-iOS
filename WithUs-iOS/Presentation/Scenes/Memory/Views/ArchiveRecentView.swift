//
//  ArchiveRecentView.swift
//  WithUs-iOS
//
//  Created on 2/2/26.
//

import UIKit
import SnapKit
import Then

protocol ArchiveRecentViewDelegate: AnyObject {
    func didSelectPhoto(_ photo: ArchivePhotoViewModel)
    func didScrollToBottomRecent()
    func didChangeSelection(count: Int)
}

final class ArchiveRecentView: UIView {
    
    weak var delegate: ArchiveRecentViewDelegate?
    
    private var photos: [ArchivePhotoViewModel] = []
    private var selectedIndexes: Set<Int> = [] {
        didSet {
            delegate?.didChangeSelection(count: selectedIndexes.count)
        }
    }
    
    var isSelectionMode: Bool = false {
        didSet {
            if !isSelectionMode {
                selectedIndexes.removeAll()
            }
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupCellRegistration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupCellRegistration() {
        collectionView.register(
            ArchivePhotoCell.self,
            forCellWithReuseIdentifier: ArchivePhotoCell.reuseId
        )
    }
    private func createLayout() -> UICollectionViewLayout {
        let screenWidth = UIScreen.main.bounds.width
        let horizontalSpacing: CGFloat = 3
        let totalHorizontalSpacing = horizontalSpacing * 2
        let itemWidth = (screenWidth - totalHorizontalSpacing) / 3
        let itemHeight = itemWidth * (16.0 / 9.0)
        
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
    
    func updatePhotos(_ photos: [ArchivePhotoViewModel]) {
        self.photos = photos
        collectionView.reloadData()
    }
    
    private func shouldShowDate(at index: Int) -> Bool {
        guard index < photos.count else { return false }
        
        if index == 0 {
            return true
        }
        
        let currentDate = photos[index].date
        let previousDate = photos[index - 1].date
        
        return currentDate != previousDate
    }
    
    private func formatDate(_ dateString: String) -> String {
        let components = dateString.split(separator: "-")
        guard components.count == 3,
              let month = Int(components[1]),
              let day = Int(components[2]) else {
            return dateString
        }
        return "\(month)월 \(day)일"
    }
    
    func getSelectedPhotos() -> [ArchivePhotoViewModel] {
        return selectedIndexes.map { photos[$0] }
    }
}

extension ArchiveRecentView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArchivePhotoCell.reuseId,
            for: indexPath
        ) as! ArchivePhotoCell
        
        let photo = photos[indexPath.item]
        let showDate = shouldShowDate(at: indexPath.item)
        let dateText = formatDate(photo.date)
        let isSelected = selectedIndexes.contains(indexPath.item)
        
        cell.configure(
            photo: photo,
            showDate: showDate,
            dateText: dateText,
            isSelectionMode: isSelectionMode,
            isSelected: isSelected
        )
        
        return cell
    }
}

extension ArchiveRecentView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isSelectionMode {
            if selectedIndexes.contains(indexPath.item) {
                selectedIndexes.remove(indexPath.item)
            } else {
                selectedIndexes.insert(indexPath.item)
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            let photo = photos[indexPath.item]
            delegate?.didSelectPhoto(photo)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.height
        
        if offsetY > contentHeight - frameHeight - 100 {
            delegate?.didScrollToBottomRecent()
        }
    }
}
