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
        return "https://withus.p-e.kr"
    }
    
    public var headers: HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]
        
        if let token = TokenManager.shared.accessToken {
            headers.add(.authorization(bearerToken: token))
        }
//        #warning("토큰 test중")
//        headers.add(.authorization(bearerToken: "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwibmlja25hbWUiOiJ0ZW1wVXNlcjEiLCJpYXQiOjE3Njg4MjM1NzMsImV4cCI6NDkyMjQyMzU3M30.nM9TzG6eZBemZlKSsy7ma5od8F7NCzAgXetpxeZe_O0"))
        return headers
    }
    
    public var parameters: Parameters? {
        return nil
    }
    
    public var encoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
    
    public var url: String {
        return baseURL + path
    }
}
