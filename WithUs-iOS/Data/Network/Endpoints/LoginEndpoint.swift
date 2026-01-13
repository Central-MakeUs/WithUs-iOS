//
//  LoginEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Alamofire

enum LoginEndpoint {
    case socialLogin(provider: SocialProvider, oauthToken: String, fcmToken: String?)
}

enum SocialProvider: String {
    case kakao = "kakao"
    case apple = "apple"
}

extension LoginEndpoint: EndpointProtocol {
    var method: HTTPMethod { .post }
    
    var path: String {
        switch self {
        case .socialLogin(let provider, _, _):
            return "/api/auth/login/\(provider.rawValue)"
        }
    }
    
    var parameterEncoding: ParameterEncoding { URLEncoding.default }
    
    var parameters: Parameters? {
        switch self {
        case .socialLogin(_, let oauthToken, let fcmToken):
            var params: [String: Any] = [
                "oauthToken": oauthToken
            ]
            
            if let fcmToken = fcmToken {
                params["fcmToken"] = fcmToken
            }
            
            return params
        }
    }
}
