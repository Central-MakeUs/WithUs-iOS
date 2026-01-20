//
//  UserOnboardingStatusResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Foundation

struct UserStatusResponse: Decodable {
    let onboardingStatus: OnboardingStatus
    
    enum CodingKeys: String, CodingKey {
        case onboardingStatus = "status"
    }
}
