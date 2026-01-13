//
//  UserEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation
import Alamofire

enum UserEndpoint {
    case updateProfile(nickname: String, imageObjectKey: String?)
}

extension UserEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .updateProfile:
            return "/api/me/user"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .updateProfile:
            return .patch
        }
    }
    
    // request body, parameter 방식 둘다 상관없이 parametrs를 사용한다.
    var parameters: Parameters? {
        switch self {
        case .updateProfile(let nickname, let imageObjectKey):
            var params: [String: Any] = [
                "nickname": nickname
            ]
            
            if let imageObjectKey = imageObjectKey {
                params["imageObjectKey"] = imageObjectKey
            }
            
            return params
        }
    }
}
