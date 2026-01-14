//
//  InvitationCodeEndPoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Alamofire

enum InvitationCodeEndPoint {
    case getInviteCode
}

extension InvitationCodeEndPoint: EndpointProtocol {
    var path: String {
        return "/api/me/user/invitation-codes"
    }

    var method: HTTPMethod { .post }
}
