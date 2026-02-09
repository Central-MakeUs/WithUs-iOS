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
    
    var path: String {
         return "/api/users/me"
    }
    
    var method: HTTPMethod {
        return .delete
    }
}
