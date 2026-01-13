//
//  LoginReactor.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation
import ReactorKit
import RxSwift
import KakaoSDKUser

final class LoginReactor: Reactor {
        
    enum Action {
        case kakaoLogin
        case appleLogin
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setLoginSuccess(isInitialized: Bool)
        case setError(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var loginResult: LoginResult?
        var errorMessage: String?
    }
    
    enum LoginResult {
        case needsSignup
        case goToMain
    }
    
    let initialState: State
    private let kakaoLoginUseCase: KakaoLoginUseCaseProtocol
    weak var coordinator: AuthCoordinator?
    
    init(
        kakaoLoginUseCase: KakaoLoginUseCaseProtocol
    ) {
        self.initialState = State()
        self.kakaoLoginUseCase = kakaoLoginUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .kakaoLogin:
            return kakaoLoginFlow()
            
        case .appleLogin:
            return .just(.setError("Apple 로그인은 준비 중입니다."))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
            
        case .setLoginSuccess(let isInitialized):
            newState.isLoading = false
            newState.errorMessage = nil
            
            if isInitialized {
                newState.loginResult = .goToMain
            } else {
                newState.loginResult = .needsSignup
            }
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            newState.loginResult = nil
        }
        
        return newState
    }
    
    private func kakaoLoginFlow() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let oauthToken = try await self.kakaoLogin()
                        
                        let result = try await self.kakaoLoginUseCase.execute(
                            oauthToken: oauthToken,
                            fcmToken: ""
                        )
                        
                        print(result.isInitialized)
                        print(result.needsProfileSetup)
                        
                        observer.onNext(.setLoginSuccess(isInitialized: result.isInitialized))
                        observer.onCompleted()
                        
                    } catch let error as KakaoLoginError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                        
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("로그인에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        ])
    }
    
    private func kakaoLogin() async throws -> String {
        let isApp = UserApi.isKakaoTalkLoginAvailable()
        
        if isApp {
            return try await loginWithKakaoTalk()
        } else {
            return try await loginWithKakaoAccount()
        }
    }
    
    @MainActor
    private func loginWithKakaoTalk() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                guard let error else {
                    if let accessToken = oauthToken?.accessToken {
                        continuation.resume(returning: accessToken)
                    }
                    
                    return
                }
                continuation.resume(throwing: error)
            }
        }
    }
    
    @MainActor
    private func loginWithKakaoAccount() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                guard let error else {
                    if let accessToken = oauthToken?.accessToken {
                        continuation.resume(returning: accessToken)
                    }
                    
                    return
                }
                
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func getFCMToken() -> String? {
        // TODO: Firebase Messaging에서 FCM 토큰 가져오기
        return nil
    }
}
