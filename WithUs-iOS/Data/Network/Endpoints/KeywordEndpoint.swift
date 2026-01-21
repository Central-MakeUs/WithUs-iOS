//
//  KeywordEndpoint.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Alamofire

enum KeywordEndpoint {
    case fetchKeyword
}

extension KeywordEndpoint: EndpointProtocol {
    var path: String {
        return "/api/keywords"
    }
    
    var method: Alamofire.HTTPMethod {
        .get
    }
}
