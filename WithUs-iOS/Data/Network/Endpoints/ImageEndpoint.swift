//
//  ImageEndpoint.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import Alamofire

enum ImageEndpoint {
    case getPresignedURL(imageType: ImageType)
}

enum ImageType: String {
    case profile = "PROFILE"
    case memory = "MEMORY"
}

extension ImageEndpoint: EndpointProtocol {
    var path: String {
        switch self {
        case .getPresignedURL:
            return "/api/images/presigned-url"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getPresignedURL:
            return .post
        }
    }
    
    var parameters: Parameters? {
        switch self {
        case .getPresignedURL(let imageType):
            return [
                "imageType": imageType.rawValue
            ]
        }
    }
}
