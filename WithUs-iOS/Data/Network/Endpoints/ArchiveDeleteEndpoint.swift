//
//  ArchiveDeleteEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/20/26.
//

import Foundation
import Alamofire

enum ArchiveDeleteEndpoint: EndpointProtocol {
    case archiveDelete(archiveType: String, id: Int, date: String)
    case archiveBulkDelete(items: [ArchiveDeleteItem])
    
    var path: String {
        switch self {
        case .archiveDelete:
            return "/api/me/couple/archives"
        case .archiveBulkDelete:
            return "/api/me/couple/archives/bulk"
        }
    }

    var method: Alamofire.HTTPMethod {
        return .delete
    }
    
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var parameters: Parameters? {
        switch self {
        case .archiveDelete(let archiveType, let id, let date):
            return ["archiveType": archiveType, "id": id, "date": date]
            
        case .archiveBulkDelete(let items):
            let itemsArray = items.map { item -> [String: Any] in
                ["archiveType": item.archiveType, "id": item.id, "date": item.date]
            }
            return ["items": itemsArray]
        }
    }
}
