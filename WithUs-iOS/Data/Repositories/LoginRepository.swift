//
//  LoginRepository.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

protocol LoginRepositoryProtocol {
    func socialLogin(
        provider: SocialProvider,
        oauthToken: String,
        fcmToken: String?
    ) async throws -> SocialLoginResponse
}

final class LoginRepository: LoginRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func socialLogin(
        provider: SocialProvider,
        oauthToken: String,
        fcmToken: String?
    ) async throws -> SocialLoginResponse {
        let endpoint = LoginEndpoint.socialLogin(
            provider: provider,
            oauthToken: oauthToken,
            fcmToken: fcmToken
        )
        
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: SocialLoginResponse.self
        )
       
        print("response.jwt: \(response.jwt)")
        TokenManager.shared.accessToken = response.jwt
        return response
    }
}
