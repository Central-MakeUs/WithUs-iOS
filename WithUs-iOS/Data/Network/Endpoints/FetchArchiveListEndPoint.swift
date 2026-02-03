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
    case fetchQuestionDetail(coupleQuestionId: Int)
    case fetchPhotoDetail(date: String, targetId: Int?, targetType: String?)
    
    var path: String {
        switch self {
        case .fetchArchiveList:
            return "/api/me/couple/archives"
        case .fetchArchiveCalendar:
            return "/api/me/couple/archives/calendar"
        case .fetchArchiveQuestionList:
            return "/api/me/couple/archives/questions"
        case .fetchQuestionDetail(let coupleQuestionId):
            return "/api/me/couple/archives/questions/\(coupleQuestionId)"
        case .fetchPhotoDetail:
            return "/api/me/couple/archives/date"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .fetchArchiveList, .fetchArchiveCalendar, .fetchArchiveQuestionList, .fetchQuestionDetail, .fetchPhotoDetail:
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
        case .fetchQuestionDetail:
            return nil
        case .fetchPhotoDetail(date: let date, targetId: let targetId, targetType: let targetType):
            var queryParams: [String: String] = [
                "date": "\(date)"
            ]
            
            if let targetId, let targetType {
                queryParams["targetId"] = "\(targetId)"
                queryParams["targetType"] = "\(targetType)"
            }
            return queryParams
        }
    }
}
