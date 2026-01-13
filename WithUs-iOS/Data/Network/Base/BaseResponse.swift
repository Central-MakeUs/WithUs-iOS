//
//  BaseResponse.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

public struct BaseResponse<T: Decodable>: Decodable {
    public let success: Bool
    public let data: T?
    public let error: ErrorResponse?
}

public struct ErrorResponse: Decodable {
    public let message: String
    public let code: String
}

public struct EmptyResponse: Decodable {
    // success만 있는 경우 사용
}
