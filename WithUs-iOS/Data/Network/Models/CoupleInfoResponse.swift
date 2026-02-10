//
//  CoupleInfoResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation

struct ProfileData: Codable {
    let meProfile: UserProfile
    let partnerProfile: UserProfile
}

struct UserProfile: Codable {
    let nickname: String
    let birthday: String
    let profileImageUrl: String?
}
