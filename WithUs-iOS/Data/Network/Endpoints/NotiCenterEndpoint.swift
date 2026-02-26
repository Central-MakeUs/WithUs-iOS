//
//  NotiCenterEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/26/26.
//

import Foundation
import Alamofire

enum NotiCenterEndpoint: EndpointProtocol {
    case fetchNotiCenter(size: Int, cursor: String?)
    
    var path: String {
        switch self {
        case .fetchNotiCenter:
            return "/api/me/notifications"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchNotiCenter(size: let size, cursor: let cursor):
            var queryParams: [String: String] = ["size": "\(size)"]
            if let cursor = cursor {
                queryParams["cursor"] = cursor
            }
            return queryParams
        }
    }
}
