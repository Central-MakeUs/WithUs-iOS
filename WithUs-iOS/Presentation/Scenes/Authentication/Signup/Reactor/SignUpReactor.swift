//
//  SignUpReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import ReactorKit
import RxSwift

final class SignUpReactor: Reactor {
    
    enum Action {
        case selectImage(Data)
        case updateNickname(String)
        case completeProfile
    }
    
    enum Mutation {
        case setProfileImage(Data)
        case setNickname(String)
        case setLoading(Bool)
        case setSuccess
        case setError(String)
    }
    
    struct State {
        var profileImage: Data?
        var nickname: String = ""
        var isLoading: Bool = false
        var isCompleted: Bool = false
        var errorMessage: String?
    }
    
    let initialState = State()
    private let completeProfileUseCase: CompleteProfileUseCaseProtocol
    
    init(completeProfileUseCase: CompleteProfileUseCaseProtocol) {
        self.completeProfileUseCase = completeProfileUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectImage(let imageData):
            return .just(.setProfileImage(imageData))
            
        case .updateNickname(let nickname):
            return .just(.setNickname(nickname))
            
        case .completeProfile:
            return completeProfileFlow()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setProfileImage(let imageData):
            newState.profileImage = imageData
            
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setSuccess:
            newState.isLoading = false
            newState.isCompleted = true
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func completeProfileFlow() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let result = try await self.completeProfileUseCase.execute(
                            nickname: self.currentState.nickname,
                            profileImage: self.currentState.profileImage
                        )
                        
                        print("✅ 프로필 설정 완료!")
                        print("   userId: \(result.userId)")
                        print("   nickname: \(result.nickname)")
                        print("   profileImageUrl: \(result.profileImageUrl ?? "없음")")
                        
                        observer.onNext(.setSuccess)
                        observer.onCompleted()
                        
                    } catch let error as UploadImageError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                        
                    } catch let error as ValidationError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("프로필 설정에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}
