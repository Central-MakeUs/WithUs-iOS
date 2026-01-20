//
//  SocialLoginReponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

enum OnboardingStatus: String, Decodable {
    case needUserSetup = "NEED_USER_INITIAL_SETUP"
    case needCoupleConnect = "NEED_COUPLE_CONNECT"
    case needCoupleSetup = "NEED_COUPLE_INITIAL_SETUP"
    case completed = "COMPLETED"
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = OnboardingStatus(rawValue: rawValue) ?? .needUserSetup
    }
}

struct SocialLoginResponse: Decodable {
    let jwt: String
    let onboardingStatus: OnboardingStatus
    
    enum CodingKeys: String, CodingKey {
        case jwt
        case onboardingStatus = "onboardingStatus"
    }
}
