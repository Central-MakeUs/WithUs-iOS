//
//  MemoryContentEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Alamofire

enum MemoryContentEndpoint: EndpointProtocol {
    case uploadImage(imageKey: String, title: String)
    case fetchImage(year: Int, month: Int)
    case makeMemory(weekEndDate: String, imageKey: String)
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/api/me/couple/memories"
        case .fetchImage:
            return "/api/me/couple/memories"
        case .makeMemory(let weekEndDate, _):
            return "/api/me/couple/memories/\(weekEndDate)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadImage, .makeMemory:
            return .post
        case .fetchImage:
            return .get
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .uploadImage(imageKey: let imageKey, title: let title):
            return ["imageKey": imageKey, "title": title]
        case .fetchImage(year: let year, month: let month):
            let monthString = String(format: "%02d", month)
            let monthKeyString = "\(year)\(monthString)"
            let monthKeyInt = Int(monthKeyString) ?? 0
            return ["monthKey": monthKeyInt]
        case .makeMemory(weekEndDate: _, imageKey: let imageKey):
            return ["imageKey": imageKey]
        }
    }
}
