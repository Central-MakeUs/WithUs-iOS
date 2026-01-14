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
//        
//        if let token = TokenManager.shared.accessToken {
//            headers.add(.authorization(bearerToken: token))
//        }
        
        headers.add(.authorization(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwibmlja25hbWUiOiJHVUVTVF80Njk1NDEyNjI5IiwiaWF0IjoxNzY4MzU2NzgzLCJleHAiOjE3NjgzOTk5ODN9.bceQZGkexsqtC09kkGc1Eiv4PLVVrSsM4RdMb9Pl1EA"))
        
        return headers
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var encoding: ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default //parameter(url뒤에 붙임)
        default:
            return JSONEncoding.default //request body(parameter)
        }
    }
    
    public var url: String {
        return baseURL + path
    }
}
