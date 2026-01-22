//
//  TodayQuestionResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import Foundation

struct TodayQuestionResponse: Decodable {
    let coupleQuestionId: Int?
    let question: String
    let myInfo: UserAnswerInfo?
    let partnerInfo: UserAnswerInfo?
}

struct UserAnswerInfo: Decodable {
    let userId: Int
    let name: String
    let profileImageUrl: String?
    let questionImageUrl: String?
    let answeredAt: String?
}
