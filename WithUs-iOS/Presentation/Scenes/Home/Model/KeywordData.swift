//
//  KeywordData.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import Foundation

struct KeywordCellData: Hashable {
    let keyword: Keyword
    let isSelected: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyword.id)
        hasher.combine(isSelected)
    }
}
