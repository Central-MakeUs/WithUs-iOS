//
//  CoupleKeyEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation
import Alamofire

enum CoupleKeywordEndpoint: EndpointProtocol {
    case getCoupleKeywords
    
    var path: String {
        switch self {
        case .getCoupleKeywords:
            return "/api/me/couple/keywords"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCoupleKeywords:
            return .get
        }
    }
}
