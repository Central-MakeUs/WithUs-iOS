//
//  UserDeleteEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation
import Alamofire

enum UserDeleteEndpoint: EndpointProtocol {
    case deleteUser
    case logoutUser(fcmToken: String)
    
    var path: String {
        switch self {
        case .deleteUser:
            return "/api/users/me"
        case .logoutUser:
            return "/api/auth/logout"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .deleteUser:
            return .delete
        case .logoutUser:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .deleteUser:
            return nil
        case .logoutUser(let fcmToken):
            return ["fcmToken": fcmToken]
        }
    }
}
