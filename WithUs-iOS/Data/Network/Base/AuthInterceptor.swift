//
//  AuthInterceptor.swift
//  WithUs-iOS
//

import Alamofire
import Foundation

final class AuthInterceptor: RequestInterceptor {
    
    private var isRefreshing = false
    private var pendingCompletions: [(RetryResult) -> Void] = []
    
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        if let accessToken = TokenManager.shared.accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }
    
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        if request.request?.url?.absoluteString.contains("/api/auth/refresh") == true {
            handleLogout()
            completion(.doNotRetry)
            return
        }
        
        pendingCompletions.append(completion)
        
        guard !isRefreshing else { return }
        isRefreshing = true
        
        Task {
            do {
                try await refreshToken()
                pendingCompletions.forEach { $0(.retry) }
            } catch {
                pendingCompletions.forEach { $0(.doNotRetry) }
                handleLogout()
            }
            pendingCompletions.removeAll()
            isRefreshing = false
        }
    }
    
    private func refreshToken() async throws {
        guard let refreshToken = TokenManager.shared.refreshToken else {
            throw NetworkError.unauthorized
        }
        
        let response = await AF.request(
            "https://withus.p-e.kr/api/auth/refresh",
            method: .post,
            parameters: ["refreshToken": refreshToken],
            encoding: JSONEncoding.default
        )
        .serializingData()
        .response
        
        if response.response?.statusCode == 401 {
            print("Error = 401")
            throw NetworkError.unauthorized
        }
        
        guard let data = response.data,
              let baseResponse = try? JSONDecoder().decode(BaseResponse<TokenResponse>.self, from: data),
              baseResponse.success,
              let tokens = baseResponse.data else {
            throw NetworkError.invalidResponse
        }
        
        TokenManager.shared.accessToken = tokens.accessToken
        TokenManager.shared.refreshToken = tokens.refreshToken
        print("✅ 토큰 갱신 성공")
    }
    
    private func handleLogout() {
        TokenManager.shared.clearTokens()
        UserDefaultsManager.shared.clearAllDataForLogout()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .didTokenExpired, object: nil)
        }
        print("🔐 토큰 만료 → 로그아웃 처리")
    }
}

extension Notification.Name {
    static let didTokenExpired = Notification.Name("didTokenExpired")
}
