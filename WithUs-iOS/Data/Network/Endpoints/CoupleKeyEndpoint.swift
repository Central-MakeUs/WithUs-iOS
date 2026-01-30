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
    case setCoupleKeywords(defaultKeywordIds: [Int], customKeywords: [String])
    
    var path: String {
        switch self {
        case .getCoupleKeywords, .setCoupleKeywords:
            return "/api/me/couple/keywords"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getCoupleKeywords:
            return .get
        case .setCoupleKeywords:
            return .put
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getCoupleKeywords:
            return nil
        case .setCoupleKeywords(let defaultKeywordIds, let customKeywords):
            return ["defaultKeywordIds": defaultKeywordIds, "customKeywords": customKeywords]
        }
    }
}
