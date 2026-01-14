//
//  VerifyCodePreviewResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct VerifyCodePreviewResponse: Decodable {
    let senderName: String
    let receiverName: String
    let inviteCode: String
}
