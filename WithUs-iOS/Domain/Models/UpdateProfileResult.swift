//
//  UpdateProfileResult.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation

struct UpdateProfileResult {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
    
    init(from response: UpdateProfileResponse) {
        self.userId = response.userId
        self.nickname = response.nickname
        self.profileImageUrl = response.profileImageUrl
    }
}
