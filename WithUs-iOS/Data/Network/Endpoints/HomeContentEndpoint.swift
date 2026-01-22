//
//  HomeContentEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import Alamofire

enum HomeContentEndpoint: EndpointProtocol {
    case getTodayQuestion
    case uploadQuestionImage(coupleQuestionId: Int, imageKey: String)
    case getTodayKeyword(coupleKeywordId: Int)
    case uploadKeywordImage(coupleKeywordId: Int, imageKey: String)
    
    var path: String {
        switch self {
        case .getTodayQuestion:
            return "/api/me/couple/question/today"
        case .uploadQuestionImage(let coupleQuestionId, _):
            return "/api/me/couple/questions/\(coupleQuestionId)/image"
        case .getTodayKeyword(let coupleKeywordId):
            return "/api/me/couple/keywords/\(coupleKeywordId)/today"
        case .uploadKeywordImage(let coupleKeywordId, _):
            return "/api/me/couple/keywords/\(coupleKeywordId)/today/image"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getTodayQuestion, .getTodayKeyword:
            return .get
        case .uploadQuestionImage, .uploadKeywordImage:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .uploadQuestionImage(_, let imageKey):
            return ["imageKey": imageKey]
        case .uploadKeywordImage(_, let imageKey):
            return ["imageKey": imageKey]
        default:
            return nil
        }
    }
}

