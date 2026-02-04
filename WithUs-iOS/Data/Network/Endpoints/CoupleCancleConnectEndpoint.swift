//
//  CoupleCancleConnectEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/4/26.
//

import Foundation
import Alamofire

enum CoupleCancleConnectEndpoint: EndpointProtocol {
    case cancelConnect
    
    var path: String {
        switch self {
        case .cancelConnect:
            "/api/me/couple/terminate"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .cancelConnect:
            return .post
        }
    }
}
