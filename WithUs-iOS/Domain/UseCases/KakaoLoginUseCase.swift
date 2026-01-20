//
//  KakaoLoginUseCase.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

struct SocialLoginResult {
    let userOnboardingStatus: OnboardingStatus
    
    init(response: SocialLoginResponse) {
        self.userOnboardingStatus = response.onboardingStatus
    }
}

protocol KakaoLoginUseCaseProtocol {
    func execute(oauthToken: String, fcmToken: String?) async throws -> SocialLoginResult
}

final class KakaoLoginUseCase: KakaoLoginUseCaseProtocol {
    private let repository: LoginRepositoryProtocol
    
    init(repository: LoginRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(oauthToken: String, fcmToken: String?) async throws -> SocialLoginResult {
        guard !oauthToken.isEmpty else {
            throw KakaoLoginError.emptyToken
        }
        
        let response = try await repository.socialLogin(
            provider: .kakao,
            oauthToken: oauthToken,
            fcmToken: fcmToken
        )
        
        return SocialLoginResult(response: response)
    }
}

enum KakaoLoginError: Error {
    case emptyToken
    case kakaoLoginFailed
    case cancelled
    
    var message: String {
        switch self {
        case .emptyToken:
            return "토큰이 올바르지 않습니다."
        case .kakaoLoginFailed:
            return "카카오 로그인에 실패했습니다."
        case .cancelled:
            return "로그인이 취소되었습니다."
        }
    }
}
