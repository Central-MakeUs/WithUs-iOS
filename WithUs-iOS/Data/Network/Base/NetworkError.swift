//
//  NetworkError.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

public enum NetworkError: Error {
    case disconnected
    case invalidURL
    case invalidResponse
    case serverError(message: String, code: String)
    case decodingError
    case httpError(statusCode: Int)
    case unknown(Error)
    case unauthorized
    
    public var errorDescription: String {
        switch self {
        case .disconnected:
            return "인터넷 연결이 끊어졌습니다."
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .serverError(let message, _):
            return message
        case .decodingError:
            return "데이터 변환에 실패했습니다."
        case .unknown(let error):
            return error.localizedDescription
        case .httpError(let statusCode):
            return statusCode.description
        case .unauthorized:
            return "인증이 만료되었습니다. 다시 로그인해주세요."
        }
    }
    
    public var errorCode: String? {
        switch self {
        case .serverError(_, let code):
            return code
        default:
            return nil
        }
    }
}
