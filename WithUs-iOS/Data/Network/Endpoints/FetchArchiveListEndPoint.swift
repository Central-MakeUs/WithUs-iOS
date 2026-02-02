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
    case fetchArchiveQuestionList(size: Int, cursor: String?)
    case fetchArchiveCalendar(year: Int, month: Int)
    
    var path: String {
        switch self {
        case .fetchArchiveList:
            return "/api/me/couple/archives"
        case .fetchArchiveCalendar:
            return "/api/me/couple/archives/calendar"
        case .fetchArchiveQuestionList:
            return "/api/me/couple/archives/questions"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchArchiveList, .fetchArchiveCalendar, .fetchArchiveQuestionList:
                .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .fetchArchiveList(size: let size, cursor: let cursor):
            var queryParams: [String: String] = ["size": "\(size)"]
            if let cursor = cursor {
                queryParams["cursor"] = cursor
            }
            return queryParams
        case .fetchArchiveCalendar(year: let year, month: let month):
            let queryParams: [String: String] = ["year": "\(year)", "month": "\(month)"]
            return queryParams
        case .fetchArchiveQuestionList(size: let size, cursor: let cursor):
            var queryParams: [String: String] = ["size": "\(size)"]
            if let cursor = cursor {
                queryParams["cursor"] = cursor
            }
            return queryParams
        }
    }
}
