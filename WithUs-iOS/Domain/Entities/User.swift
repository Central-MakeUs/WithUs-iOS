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
    let profileImageUrl: String?
    let birthDate: String?
    
    init(from response: UpdateProfileResponse) {
        self.userId = String(response.userId)
        self.nickname = response.nickname
        self.profileImageUrl = response.profileImageUrl
        self.birthDate = nil
    }
    
    init(from user: PutUpdateProfileResponse) {
        self.userId = String(user.userId)
        self.nickname = user.nickname
        self.profileImageUrl = user.profileImageUrl
        self.birthDate = user.birthday
    }
}
