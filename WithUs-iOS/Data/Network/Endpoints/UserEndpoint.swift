//
//  UserEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation
import Alamofire

enum UserEndpoint {
    case updateProfile(nickname: String,
                       birthday: String,
                       defaultKeywordIds: [Int],
                       customKeywords: [String],
                       imageKey: String?)
}

extension UserEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .updateProfile:
            return "/api/me/onboarding"
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
        case .updateProfile(let nickname, let birthday, let defaultKeywordIds, let customKeywords, let imageKey):
            var params: [String: Any] = [
                "nickname": nickname,
                "birthday": birthday,
                "defaultKeywordIds": defaultKeywordIds,
                "customKeywords": customKeywords
            ]
            if let imageKey = imageKey {
                params["imageKey"] = imageKey
            }
            return params
        }
    }
}
