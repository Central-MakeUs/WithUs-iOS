//
//  PartnerInfoEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation
import Alamofire

enum PartnerInfoEndpoint: EndpointProtocol {
    case getPartnerInfo
    
    var path: String {
        switch self {
        case .getPartnerInfo:
            return "/api/me/couple/profile"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPartnerInfo:
            return .get
        }
    }
}
