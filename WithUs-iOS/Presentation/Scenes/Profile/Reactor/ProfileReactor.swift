//
//  ProfileReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import Foundation
import ReactorKit
import UIKit

final class ProfileReactor: Reactor {

    enum Action {
        case viewWillAppear
        case selectImage(Data)
        case updateNickname(String)
        case updateBirthDate(String)
        case saveProfile(nickname: String, birthDate: String, image: UIImage?)
        case completeProfile
        case cancleConnect
    }
    
    enum Mutation {
        case setProfileImage(Data?)
        case setNickname(String)
        case setBirthDate(String)
        case setLoading(Bool)
        case setUser(User)
        case setUserStatus(OnboardingStatus)
        case setSuccess
        case setError(String)
        case cancleSuccess
    }
    
    struct State {
        var user: User?
        var profileImage: Data?
        var nickname: String = ""
        var birthDate: String = ""
        var isLoading: Bool = false
        var isCompleted: Bool = false
        var errorMessage: String?
        var userStatus: OnboardingStatus?
        var cancleSuccess: Bool = false
    }
    
    var initialState: State = .init()
    private let completeProfileUseCase: CompleteProfileUseCaseProtocol
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    private let cancleConnectUseCase: CoupleCancleConnectUseCaseProtocol
    
    init(
        completeProfileUseCase: CompleteProfileUseCaseProtocol,
        fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol,
        cancleConnectUseCase: CoupleCancleConnectUseCaseProtocol
    ) {
        self.completeProfileUseCase = completeProfileUseCase
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
        self.cancleConnectUseCase = cancleConnectUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveProfile(let nickname, let birthDate, let image):
            let imageData = image?.jpegData(compressionQuality: 0.7)
            return Observable.concat(
                .just(.setNickname(nickname)),
                .just(.setBirthDate(birthDate)),
                .just(.setProfileImage(imageData)),
                completeProfileFlow()
            )
            
        case .selectImage(let imageData):
            return .just(.setProfileImage(imageData))
            
        case .updateNickname(let nickname):
            return .just(.setNickname(nickname))
            
        case .completeProfile:
            return completeProfileFlow()
            
        case .updateBirthDate(let birthDate):
            return .just(.setBirthDate(birthDate))
        case .viewWillAppear:
            return fetchUserStatus()
        case .cancleConnect:
            return cancleConnect()
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
            
        case .setUser(let user):
            newState.user = user
            
        case .setUserStatus(let status):
            newState.userStatus = status
            
        case .cancleSuccess:
            newState.cancleSuccess = true
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
    
    private func fetchUserStatus() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let result = try await self.fetchUserStatusUseCase.execute()
                        observer.onNext(.setUserStatus(result))
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
    
    private func cancleConnect() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        try await self.cancleConnectUseCase.execute()
                        observer.onNext(.cancleSuccess)
                        observer.onCompleted()
                    } catch let error as UploadImageError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                        
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("연결 해제에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}
