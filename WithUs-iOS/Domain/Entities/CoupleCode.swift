//
//  CoupleCode.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct CoupleCode {
    let coupleId: String
    
    init(response: CoupleCodeResponse) {
        self.coupleId = String(response.coupleId)
    }
}
