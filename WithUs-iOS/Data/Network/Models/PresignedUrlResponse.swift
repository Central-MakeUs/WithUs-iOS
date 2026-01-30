//
//  PresignedUrlResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct PresignedUrlResponse: Decodable {
    let uploadUrl: String
    let imageKey: String
}
