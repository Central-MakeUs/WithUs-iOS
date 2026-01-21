//
//  User.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct User {
    let userId: String
    let nickname: String
    let keywords: [UserKeyword]
    let profileImageUrl: String?
    
    init(from response: UpdateProfileResponse) {
        self.userId = String(response.userId)
        self.nickname = response.nickname
        self.keywords = response.keywordInfoList.map { UserKeyword(from: $0) }
        self.profileImageUrl = response.profileImageUrl
    }
}

struct UserKeyword {
    let keywordId: String
    let content: String
    
    init(from dto: UpdateProfileResponse.KeywordInfo) {
        self.keywordId = String(dto.keywordId)
        self.content = dto.content
    }
}
