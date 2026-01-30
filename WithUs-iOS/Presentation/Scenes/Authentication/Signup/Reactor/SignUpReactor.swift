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
        case updateBirthDate(String)
        case updateKeywords(defaultKeywordIds: [Int], customKeywords: [String])
        case completeProfile
    }
    
    enum Mutation {
        case setProfileImage(Data)
        case setNickname(String)
        case setBirthDate(String)
        case setKeywords(defaultKeywordIds: [Int], customKeywords: [String])
        case setLoading(Bool)
        case setUser(User)
        case setSuccess
        case setError(String)
    }
    
    struct State {
        var user: User?
        var profileImage: Data?
        var nickname: String = ""
        var birthDate: String = ""
        var defaultKeywordIds: [Int] = []
        var customKeywords: [String] = []
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
            
        case .updateBirthDate(let birthDate):
            return .just(.setBirthDate(birthDate))
        case .updateKeywords(defaultKeywordIds: let defaultKeywordIds, customKeywords: let customKeywords):
            return .just(.setKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords))
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
            
        case .setBirthDate(let birthDate):
            newState.birthDate = birthDate
            
        case .setKeywords(let defaultKeywordIds, let customKeywords):
            newState.defaultKeywordIds = defaultKeywordIds
            newState.customKeywords = customKeywords
        case .setUser(let user):
            newState.user = user
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
                        let result = try await self.completeProfileUseCase.execute(nickname: self.currentState.nickname, birthday: self.currentState.birthDate, profileImage: self.currentState.profileImage)
                        print("   nickname: \(result.nickname)")
                        print("   userId: \(result.userId)")
                        print("   profileImageUrl: \(result.profileImageUrl ?? "없음")")
                        UserManager.shared.userId = result.userId
                        UserManager.shared.nickName = result.nickname
                        UserManager.shared.profileImageUrl = result.profileImageUrl
                        observer.onNext(.setUser(result))
                        observer.onNext(.setSuccess)
                        observer.onCompleted()
                        
                    } catch let error as UploadImageError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                        
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
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
