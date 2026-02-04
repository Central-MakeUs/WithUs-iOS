//
//  Keyword.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import Foundation

struct Keyword: Hashable {
    let id: String
    let text: String
    let displayOrder: Int
    let isAddButton: Bool
    let isSelected: Bool
    
    init(id: String, text: String, displayOrder: Int = 0, isAddButton: Bool = false, isSelected: Bool = false) {
        self.id = id
        self.text = text
        self.displayOrder = displayOrder
        self.isAddButton = isAddButton
        self.isSelected = isSelected
    }
    
    static func == (lhs: Keyword, rhs: Keyword) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct KeywordCellData: Hashable {
    let keyword: Keyword
    let isSelected: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(keyword.id)
        hasher.combine(isSelected)
    }
}
