//
//  KeywordResponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

struct KeywordResponse: Decodable {
    let keywordInfoList: [KeywordInfo]
}

struct KeywordInfo: Decodable {
    let keywordId: Int
    let content: String
    let displayOrder: Int
}

extension KeywordInfo {
    func toDomain() -> Keyword {
        return Keyword(
            id: String(keywordId),
            text: content,
            displayOrder: displayOrder
        )
    }
}

struct SelectedKeywordResponse: Decodable {
    let keywords: [SelectedKeywordInfo]
}

struct SelectedKeywordInfo: Decodable {
    let keywordId: Int
    let content: String
    let isSelected: Bool
}

extension SelectedKeywordInfo {
    func toDomain() -> Keyword {
        return Keyword(
            id: String(keywordId),
            text: content,
            displayOrder: 0
        )
    }
}
