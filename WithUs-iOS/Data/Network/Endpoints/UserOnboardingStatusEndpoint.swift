//
//  UserOnboardingStatusEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Alamofire

enum UserOnboardingStatusEndpoint {
    case fetchStatus
}

extension UserOnboardingStatusEndpoint: EndpointProtocol {
    var method: HTTPMethod { .get }

    var path: String {
        return "/api/me/status"
    }
}
