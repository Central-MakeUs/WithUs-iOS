//
//  TokenResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/12/26.
//

import Foundation

struct TokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
