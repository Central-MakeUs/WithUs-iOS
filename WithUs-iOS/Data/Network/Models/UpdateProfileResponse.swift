//
//  UpdateProfileResponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation

struct UpdateProfileResponse: Decodable {
    let userId: Int64
    let nickname: String
    let profileImageUrl: String?
}
