//
//  PutUserEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation
import Alamofire

enum PutUserEndpoint {
    case updateProfile(nickname: String,
                       birthday: String,
                       imageKey: String?)
}

extension PutUserEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .updateProfile:
            return "/api/me/user/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateProfile:
            return .put
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .updateProfile(let nickname, let birthday, let imageKey):
            var params: [String: Any] = [
                "nickname": nickname,
                "birthday": birthday,
            ]
            if let imageKey = imageKey {
                params["imageKey"] = imageKey
            }
            return params
        }
    }
}

