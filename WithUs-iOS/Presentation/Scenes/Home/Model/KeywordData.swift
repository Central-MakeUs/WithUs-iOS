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
// MARK: - Keyword Status (키워드별 상태)
enum KeywordStatus {
    case bothAnswered(myImageURL: String, partnerImageURL: String, myCaption: String, partnerCaption: String)
    case myAnswerOnly(myImageURL: String, myCaption: String)
    case partnerOnly(partnerImageURL: String, partnerCaption: String)
}

// MARK: - Keyword Data (키워드별 데이터)
struct KeywordData {
    let keywordName: String // "맛집", "여행", "데이트" 등
    let myImageURL: String?
    let partnerImageURL: String?
    let myCaption: String?
    let partnerCaption: String?
    
    var status: KeywordStatus? {
        switch (myImageURL, partnerImageURL) {
        case (let myURL?, let partnerURL?):
            // 1. 둘 다 보냄
            return .bothAnswered(
                myImageURL: myURL,
                partnerImageURL: partnerURL,
                myCaption: myCaption ?? "",
                partnerCaption: partnerCaption ?? ""
            )
            
        case (let myURL?, nil):
            // 2. 내가 보냄, 상대 안보냄
            return .myAnswerOnly(
                myImageURL: myURL,
                myCaption: myCaption ?? ""
            )
            
        case (nil, let partnerURL?):
            // 3. 상대 보냄, 내가 안보냄
            return .partnerOnly(
                partnerImageURL: partnerURL,
                partnerCaption: partnerCaption ?? ""
            )
            
        case (nil, nil):
            // 아무도 안보냄
            return nil
        }
    }
}
