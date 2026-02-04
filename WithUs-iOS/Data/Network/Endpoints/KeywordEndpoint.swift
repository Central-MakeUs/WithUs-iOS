//
//  KeywordEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Alamofire

enum KeywordEndpoint {
    case fetchKeyword
    case selectedFetchKeyword
}

extension KeywordEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .fetchKeyword:
            return "/api/keywords/default"
        case .selectedFetchKeyword:
            return "/api/me/couple/keywords/edit"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
}
