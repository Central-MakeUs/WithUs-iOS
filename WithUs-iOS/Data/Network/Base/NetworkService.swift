//
//  NetworkService.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation
import Alamofire

public final class NetworkService {
    public static let shared = NetworkService()
    
    private init() {}
    
    public func request<T: Decodable>(
        endpoint: EndpointProtocol,
        responseType: T.Type
    ) async throws -> T {
        // 네트워크 연결 확인
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        do {
            let response: BaseResponse<T> = try await AF.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .serializingDecodable(BaseResponse<T>.self)
            .value
            
            guard response.success else {
                if let error = response.error {
                    throw NetworkError.serverError(message: error.message, code: error.code)
                }
                throw NetworkError.invalidResponse
            }
            
            // data 추출
            guard let data = response.data else {
                throw NetworkError.invalidResponse
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch let decodingError as DecodingError {
            print("Decoding Error: \(decodingError)")
            throw NetworkError.decodingError
        } catch {
            print("Network Error: \(error)")
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - Request without Response Data (success만 확인)
    
    public func requestWithoutData(
        endpoint: EndpointProtocol
    ) async throws {
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        do {
            let response: BaseResponse<EmptyResponse> = try await AF.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .serializingDecodable(BaseResponse<EmptyResponse>.self)
            .value
            
            guard response.success else {
                if let error = response.error {
                    throw NetworkError.serverError(message: error.message, code: error.code)
                }
                throw NetworkError.invalidResponse
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    public func requestWithRawBody<T: Decodable>(
        endpoint: EndpointProtocol,
        rawBody: Data,
        responseType: T.Type
    ) async throws -> T {
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        do {
            var urlRequest = try URLRequest(url: endpoint.url, method: endpoint.method)
            endpoint.headers.forEach { header in
                urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
            }
            urlRequest.httpBody = rawBody
            
            let response: BaseResponse<T> = try await AF.request(urlRequest)
                .validate()
                .serializingDecodable(BaseResponse<T>.self)
                .value
            
            guard response.success else {
                if let error = response.error {
                    throw NetworkError.serverError(message: error.message, code: error.code)
                }
                throw NetworkError.invalidResponse
            }
            
            guard let data = response.data else {
                throw NetworkError.invalidResponse
            }
            
            return data
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    public func upload<T: Decodable>(
        endpoint: EndpointProtocol,
        responseType: T.Type,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) async throws -> T {
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: multipartFormData,
                to: endpoint.url,
                method: endpoint.method,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: BaseResponse<T>.self) { response in
                switch response.result {
                case .success(let baseResponse):
                    if baseResponse.success, let data = baseResponse.data {
                        continuation.resume(returning: data)
                    } else if let error = baseResponse.error {
                        continuation.resume(
                            throwing: NetworkError.serverError(
                                message: error.message,
                                code: error.code
                            )
                        )
                    } else {
                        continuation.resume(throwing: NetworkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.unknown(error))
                }
            }
        }
    }
    
    // MARK: - Upload without Response Data
    
    public func uploadWithoutData(
        endpoint: EndpointProtocol,
        multipartFormData: @escaping (MultipartFormData) -> Void
    ) async throws {
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                multipartFormData: multipartFormData,
                to: endpoint.url,
                method: endpoint.method,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: BaseResponse<EmptyResponse>.self) { response in
                switch response.result {
                case .success(let baseResponse):
                    if baseResponse.success {
                        continuation.resume()
                    } else if let error = baseResponse.error {
                        continuation.resume(
                            throwing: NetworkError.serverError(
                                message: error.message,
                                code: error.code
                            )
                        )
                    } else {
                        continuation.resume(throwing: NetworkError.invalidResponse)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.unknown(error))
                }
            }
        }
    }
}
