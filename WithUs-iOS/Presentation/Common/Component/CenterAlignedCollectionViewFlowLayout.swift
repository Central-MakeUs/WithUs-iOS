//
//  CenterAlignedCollectionViewFlowLayout.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/13/26.
//

import Foundation
import UIKit

final class CenterAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect)?
            .map({ $0.copy() as! UICollectionViewLayoutAttributes })
        else { return nil }
        
        guard let collectionView = collectionView, !attributes.isEmpty else { return attributes }
        
        let totalWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        
        // y값 기준으로 행 그룹핑
        var rowDict: [Int: [UICollectionViewLayoutAttributes]] = [:]
        for attribute in attributes {
            let rowKey = Int(attribute.frame.minY)
            if rowDict[rowKey] == nil {
                rowDict[rowKey] = []
            }
            rowDict[rowKey]?.append(attribute)
        }
        
        // 각 행 중앙 정렬
        for (_, row) in rowDict {
            let sortedRow = row.sorted { $0.frame.minX < $1.frame.minX }
            let rowWidth = sortedRow.reduce(0) { $0 + $1.frame.width }
                + CGFloat(sortedRow.count - 1) * minimumInteritemSpacing
            var startX = ((totalWidth - rowWidth) / 2) + sectionInset.left
            
            for attribute in sortedRow {
                var frame = attribute.frame
                frame.origin.x = startX
                attribute.frame = frame
                startX += frame.width + minimumInteritemSpacing
            }
        }
        
        return attributes
    }
}
