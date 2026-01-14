//
//  InviteVerificationAndAcceptEndPoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Alamofire

enum InviteVerificationAndAcceptEndPoint {
    case verifyCode(inviteCode: String)
    case acceptInvite(inviteCode: String)
}

extension InviteVerificationAndAcceptEndPoint: EndpointProtocol {
    var method: Alamofire.HTTPMethod {
        .post
    }

    var path: String {
        switch self {
        case .verifyCode:
            return "/api/me/couple/join/preview"
        case .acceptInvite:
            return "/api/me/couple/join"
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .verifyCode(inviteCode: let inviteCode):
            return [
                "inviteCode": inviteCode
            ]
        case .acceptInvite(inviteCode: let inviteCode):
            return [
                "inviteCode": inviteCode
            ]
        }
    }
}
