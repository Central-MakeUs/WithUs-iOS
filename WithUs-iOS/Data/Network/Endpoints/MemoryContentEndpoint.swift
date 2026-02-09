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
    case fetchDetailImage(memoryType: MemoryType, weekEndDate: String?, targetId: Int?)
    
    var path: String {
        switch self {
        case .uploadImage:
            return "/api/me/couple/memories"
        case .fetchImage:
            return "/api/me/couple/memories"
        case .makeMemory(let weekEndDate, _):
            return "/api/me/couple/memories/\(weekEndDate)"
        case .fetchDetailImage:
            return "/api/me/couple/memories/detail"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .uploadImage, .makeMemory:
            return .post
        case .fetchImage, .fetchDetailImage:
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
        case .fetchDetailImage(memoryType: let memoryType, weekEndDate: let weekEndDate, targetId: let targetId):
            var params: [String: Any] = [
                "memoryType": memoryType.rawValue
            ]
            
            if let weekEndDate {
                params["weekEndDate"] = weekEndDate
            }
            
            if let targetId {
                params["targetId"] = targetId
            }
            
            return params
        }
    }
}
