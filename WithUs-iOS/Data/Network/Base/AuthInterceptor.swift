//
//  AuthInterceptor.swift
//  WithUs-iOS
//

import Alamofire
import Foundation

extension Notification.Name {
    static let didTokenExpired = Notification.Name("didTokenExpired")
}

struct TokenCredential: AuthenticationCredential {
    var accessToken: String { TokenManager.shared.accessToken ?? "" }
    var refreshToken: String { TokenManager.shared.refreshToken ?? "" }
    var requiresRefresh: Bool = false
}

final class TokenAuthenticator: Authenticator {
    private var isRefreshFailed = false
    
    func apply(_ credential: TokenCredential, to urlRequest: inout URLRequest) {
        urlRequest.setValue("Bearer \(credential.accessToken)", forHTTPHeaderField: "Authorization")
    }
    
    func refresh(
        _ credential: TokenCredential,
        for session: Session,
        completion: @escaping (Result<TokenCredential, Error>) -> Void
    ) {
        print("🔄 [리프레시 요청] POST /api/auth/refresh")
        
        AF.request(
            "https://withus.p-e.kr/api/auth/refresh",
            method: .post,
            parameters: ["refreshToken": credential.refreshToken],
            encoding: JSONEncoding.default,
            headers: ["Authorization": "Bearer \(credential.accessToken)"]
        )
        .responseData { [weak self] response in
            let statusCode = response.response?.statusCode ?? -1
            print("🔄 [리프레시 응답] statusCode: \(statusCode)")
            if statusCode == 401 {
                print("❌ [리프레시 응답] 401 → 리프레시 토큰 만료 → 로그아웃")
                self?.isRefreshFailed = true
                self?.handleLogout()
                completion(.failure(NetworkError.unauthorized))
                return
            }
            
            guard let data = response.data,
                  let baseResponse = try? JSONDecoder().decode(BaseResponse<TokenResponse>.self, from: data),
                  baseResponse.success,
                  let tokens = baseResponse.data else {
                print("❌ [리프레시 응답] 파싱 실패")
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            print("✅ 토큰 갱신 성공")
            self?.isRefreshFailed = false
            TokenManager.shared.accessToken = tokens.accessToken
            TokenManager.shared.refreshToken = tokens.refreshToken
            completion(.success(TokenCredential()))
        }
    }
    
    func didRequest(
        _ urlRequest: URLRequest,
        with response: HTTPURLResponse,
        failDueToAuthenticationError error: Error
    ) -> Bool {
        if isRefreshFailed { return false }
        return response.statusCode == 401
    }

    func isRequest(
        _ urlRequest: URLRequest,
        authenticatedWith credential: TokenCredential
    ) -> Bool {
        if isRefreshFailed { return false }
        let bearerToken = "Bearer \(credential.accessToken)"
        return urlRequest.value(forHTTPHeaderField: "Authorization") == bearerToken
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
