//
//  Keyword.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import Foundation

struct Keyword: Hashable {
    let id: UUID
    let text: String
    let isAddButton: Bool
    
    init(id: UUID = UUID(), text: String, isAddButton: Bool = false) {
        self.id = id
        self.text = text
        self.isAddButton = isAddButton
    }
    
    static func == (lhs: Keyword, rhs: Keyword) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
