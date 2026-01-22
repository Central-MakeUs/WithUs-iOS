//
//  TodayKeywordResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import Foundation

struct TodayKeywordResponse: Decodable {
    let coupleKeywordId: Int
    let question: String
    let myInfo: UserAnswerInfo?
    let partnerInfo: UserAnswerInfo?
}
