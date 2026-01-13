//
//  KakaoLoginResult.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

struct SocialLoginResult {
    let isInitialized: Bool
    let needsProfileSetup: Bool
    
    init(response: SocialLoginResponse) {
        self.isInitialized = response.isInitialized
        self.needsProfileSetup = !response.isInitialized
    }
}
