//
//  CoupleKeywordResponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

struct CoupleKeywordDataResponse: Decodable {
    let coupleKeywords: [CoupleKeywordInfo]
}

struct CoupleKeywordInfo: Decodable {
    let keywordId: Int
    let coupleKeywordId: Int
    let content: String
}

extension CoupleKeywordInfo {
    func toDomain() -> Keyword {
        return Keyword(
            id: String(coupleKeywordId),
            text: content,
            displayOrder: 0,
            isAddButton: false
        )
    }
}
