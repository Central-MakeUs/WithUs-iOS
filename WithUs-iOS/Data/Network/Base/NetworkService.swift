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
        guard NetworkMonitor.shared.isConnected else {
            throw NetworkError.disconnected
        }
        
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 API 요청")
        print("URL: \(endpoint.url)")
        print("Method: \(endpoint.method)")
        print("Headers: \(endpoint.headers)")
        print("Parameters: \(endpoint.parameters ?? [:])")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        do {
            // ✅ 1. Raw Data 먼저 받기
            let rawDataResponse = await AF.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .cURLDescription { description in
                print("📤 cURL: \(description)")
            }
            .serializingData()
            .response
#warning("refreshToken으로 accessToken을 갱신해주고 둘다 만료시 logout로직 필요")
            // ✅ 2. Raw JSON 출력
            if let data = rawDataResponse.data {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("📦 Raw JSON Response:")
                
                if let jsonString = String(data: data, encoding: .utf8) {
                    print(jsonString)
                }
                
                // Pretty Print (더 보기 좋게)
                if let jsonObject = try? JSONSerialization.jsonObject(with: data),
                   let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
                   let prettyString = String(data: prettyData, encoding: .utf8) {
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("📝 Pretty JSON:")
                    print(prettyString)
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            }
            
            // ✅ 3. Status Code 확인
            if let statusCode = rawDataResponse.response?.statusCode {
                print("Status Code: \(statusCode)")
                
                if (400...599).contains(statusCode) {
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("⚠️ HTTP Error \(statusCode)")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    // BaseResponse 디코딩 시도
                    if let data = rawDataResponse.data {
                        if let baseResponse = try? JSONDecoder().decode(BaseResponse<T>.self, from: data) {
                            if !baseResponse.success, let error = baseResponse.error {
                                print("📝 서버 에러 메시지: \(error.message)")
                                print("🔢 서버 에러 코드: \(error.code)")
                                throw NetworkError.serverError(message: error.message, code: error.code)
                            }
                        }
                    }
                    
                    throw NetworkError.httpError(statusCode: statusCode)
                }
            }
            
            // ✅ 4. 디코딩
            guard let data = rawDataResponse.data else {
                throw NetworkError.invalidResponse
            }
            
            do {
                let response = try JSONDecoder().decode(BaseResponse<T>.self, from: data)
                
                print("✅ 응답 성공: \(response.success)")
                
                guard response.success else {
                    if let error = response.error {
                        throw NetworkError.serverError(message: error.message, code: error.code)
                    }
                    throw NetworkError.invalidResponse
                }
                
                guard let responseData = response.data else {
                    throw NetworkError.invalidResponse
                }
                
                return responseData
                
            } catch let decodingError as DecodingError {
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                print("❌ Decoding Error Details:")
                
                switch decodingError {
                case .typeMismatch(let type, let context):
                    print("Type Mismatch: \(type)")
                    print("Context: \(context)")
                case .valueNotFound(let type, let context):
                    print("Value Not Found: \(type)")
                    print("Context: \(context)")
                case .keyNotFound(let key, let context):
                    print("Key Not Found: \(key)")
                    print("Context: \(context)")
                case .dataCorrupted(let context):
                    print("Data Corrupted")
                    print("Context: \(context)")
                @unknown default:
                    print("Unknown decoding error")
                }
                print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                
                throw NetworkError.decodingError
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            print("❌ Network Error: \(error)")
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
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        print("🌐 API 요청")
        print("URL: \(endpoint.url)")
        print("Method: \(endpoint.method)")
        print("Headers: \(endpoint.headers)")
        print("Parameters: \(endpoint.parameters ?? [:])")
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        
        do {
            let dataResponse = await AF.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
                .cURLDescription { description in
                    print("📤 cURL: \(description)")  // ✅ 실제 요청 확인
                }
                .serializingDecodable(BaseResponse<EmptyResponse>.self)
                .response
            
            // 상태 코드 확인
            if let statusCode = dataResponse.response?.statusCode {
                print("Status Code: \(statusCode)")
                
                if (400...599).contains(statusCode) {
                    
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    print("⚠️ HTTP Error \(statusCode) - 서버 에러 메시지 확인 중...")
                    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
                    
                    if case .success(let baseResponse) = dataResponse.result {
                        if !baseResponse.success, let error = baseResponse.error {
                            
                            print("📝 서버 에러 메시지: \(error.message)")
                            print("🔢 서버 에러 코드: \(error.code)")
                            
                            throw NetworkError.serverError(message: error.message, code: error.code)
                        }
                    }
                    print("→ 서버 에러 메시지 없음, 기본 HTTP 에러 처리")
                    throw NetworkError.httpError(statusCode: statusCode)
                }
            }
            
            guard case .success(let response) = dataResponse.result else {
                if let error = dataResponse.error {
                    throw NetworkError.unknown(error)
                }
                throw NetworkError.invalidResponse
            }
            
            print("✅ 응답 성공: \(response.success)")
            
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
            
            let dataResponse = await AF.request(urlRequest)
                .serializingDecodable(BaseResponse<T>.self)
                .response
            
            // 상태 코드 확인
            if let statusCode = dataResponse.response?.statusCode {
                if (400...599).contains(statusCode) {
                    if case .success(let baseResponse) = dataResponse.result {
                        if !baseResponse.success, let error = baseResponse.error {
                            throw NetworkError.serverError(message: error.message, code: error.code)
                        }
                    }
                    throw NetworkError.httpError(statusCode: statusCode)
                }
            }
            
            guard case .success(let response) = dataResponse.result else {
                if let error = dataResponse.error {
                    throw NetworkError.unknown(error)
                }
                throw NetworkError.invalidResponse
            }
            
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
    
    public func uploadToS3(url: String, imageData: Data) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let headers: HTTPHeaders = [
                "Content-Type": "image/jpeg"
            ]
            
            AF.upload(imageData, to: url, method: .put, headers: headers)
                .validate()
                .response { response in
                    switch response.result {
                    case .success:
                        print("✅ S3 업로드 성공 (JPG)")
                        continuation.resume()
                        
                    case .failure(let error):
                        print("❌ S3 업로드 실패: \(error)")
                        continuation.resume(throwing: NetworkError.unknown(error))
                    }
                }
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
            .responseDecodable(of: BaseResponse<T>.self) { response in
                // 상태 코드 확인
                if let statusCode = response.response?.statusCode, (400...599).contains(statusCode) {
                    if case .success(let baseResponse) = response.result {
                        if !baseResponse.success, let error = baseResponse.error {
                            continuation.resume(
                                throwing: NetworkError.serverError(
                                    message: error.message,
                                    code: error.code
                                )
                            )
                            return
                        }
                    }
                    continuation.resume(throwing: NetworkError.httpError(statusCode: statusCode))
                    return
                }
                
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
            .responseDecodable(of: BaseResponse<EmptyResponse>.self) { response in
                // 상태 코드 확인
                if let statusCode = response.response?.statusCode, (400...599).contains(statusCode) {
                    if case .success(let baseResponse) = response.result {
                        if !baseResponse.success, let error = baseResponse.error {
                            continuation.resume(
                                throwing: NetworkError.serverError(
                                    message: error.message,
                                    code: error.code
                                )
                            )
                            return
                        }
                    }
                    continuation.resume(throwing: NetworkError.httpError(statusCode: statusCode))
                    return
                }
                
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
