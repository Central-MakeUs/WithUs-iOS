//
//  FetchArchiveListEndPoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation
import Alamofire

enum FetchArchiveListEndPoint: EndpointProtocol {
    case fetchArchiveList(size: Int, cursor: String?)
    
    var path: String {
        "/api/me/couple/archives"
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchArchiveList:
                .get
        }
    }
    
    var prarameters: Parameters? {
        switch self {
        case .fetchArchiveList(size: let size, cursor: let cursor):
            var queryParams: [String: String] = ["size": "\(size)"]
            if let cursor = cursor {
                queryParams["cursor"] = cursor
            }
            return queryParams
        }
    }
}
