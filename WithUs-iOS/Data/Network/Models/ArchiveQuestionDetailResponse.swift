//
//  ArchiveQuestionDetailResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/3/26.
//

import Foundation

struct ArchiveQuestionDetailResponse: Decodable {
    let coupleQuestionId: Int
    let questionNumber: Int
    let questionContent: String
    let myInfo: UserArchiveInfo
    let partnerInfo: UserArchiveInfo
}

struct UserArchiveInfo: Decodable {
    let userId: Int
    let name: String
    let profileThumbnailImageUrl: String?
    let answerImageUrl: String?
    let answeredAt: String?
}
