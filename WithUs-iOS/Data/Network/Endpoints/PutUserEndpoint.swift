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
                       imageKey: String?,
                       isImageUpdated: Bool)
    case getProfile
}

extension PutUserEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .updateProfile:
            return "/api/me/user/profile"
        case .getProfile:
            return "/api/me/user/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateProfile:
            return .put
        case .getProfile:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .updateProfile(let nickname, let birthday, let imageKey, let isImageUpdated):
            var params: [String: Any] = [
                "nickname": nickname,
                "birthday": birthday,
                "isImageUpdated": isImageUpdated
            ]
            if let imageKey = imageKey {
                params["imageKey"] = imageKey
            }
            return params
        case .getProfile:
            return nil
        }
    }
}

