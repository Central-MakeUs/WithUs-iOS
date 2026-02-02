//
//  ArchiveQuestionListResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

struct ArchiveQuestionListResponse: Decodable {
    let questionList: [ArchiveQuestionItem]
    let hasNext: Bool
    let nextCursor: String?
}

struct ArchiveQuestionItem: Decodable {
    let coupleQuestionId: Int
    let questionNumber: Int
    let questionContent: String
}
