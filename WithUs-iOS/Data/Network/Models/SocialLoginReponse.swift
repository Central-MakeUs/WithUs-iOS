//
//  SocialLoginReponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

struct SocialLoginResponse: Decodable {
    let jwt: String
    let isInitialized: Bool
}
