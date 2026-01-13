//
//  EndpointProtocol.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation
import Alamofire

public protocol EndpointProtocol {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HTTPHeaders { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

extension EndpointProtocol {
    public var baseURL: String {
        return "http://withus.p-e.kr" // TODO: 실제 baseURL로 변경
    }
    
    public var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        // JWT 토큰이 있으면 추가
        if let token = TokenManager.shared.accessToken {
            headers.add(.authorization(bearerToken: token))
        }
        
        return headers
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    public var url: String {
        return baseURL + path
    }
}
