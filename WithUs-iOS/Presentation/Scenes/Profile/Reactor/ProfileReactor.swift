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
        case saveProfile(nickname: String, birthDate: String, image: UIImage?, isImageUpdated: Bool)
        case completeProfile
        case cancleConnect
        case deleteAccount
        case logoutAccount
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
        case deleteSuccess
        case logoutSuccess
        case resetCompleted
        case setCoupleInfo(ProfileData)
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
        var deleteSuccess: Bool = false
        var logoutSuccess: Bool = false
        var coupleInfo: ProfileData?
    }
    
    var initialState: State = .init()
    private let completeProfileUseCase: UpdateProfileUseCaseProtocol
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    private let cancleConnectUseCase: CoupleCancleConnectUseCaseProtocol
    private let fetchUserInfoUseCase: FetchUserInfoUseCaseProtocol
    private let deleteUserUseCase: UserDeleteUsecaseProtocol
    private let coupleInfoUsecase: CoupleInfoUsecaseProtocol
    
    init(
        completeProfileUseCase: UpdateProfileUseCaseProtocol,
        fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol,
        cancleConnectUseCase: CoupleCancleConnectUseCaseProtocol,
        fetchUserInfoUseCase: FetchUserInfoUseCaseProtocol,
        deleteUserUseCase: UserDeleteUsecaseProtocol,
        coupleInfoUseCase: CoupleInfoUsecaseProtocol
    ) {
        self.completeProfileUseCase = completeProfileUseCase
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
        self.cancleConnectUseCase = cancleConnectUseCase
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.deleteUserUseCase = deleteUserUseCase
        self.coupleInfoUsecase = coupleInfoUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveProfile(let nickname, let birthDate, let image, let isImageUpdated):
            let imageData = image?.jpegData(compressionQuality: 0.7)
            return Observable.concat(
                completeProfileFlow(nickname: nickname, birthDate: birthDate, image: imageData, isImageUpdated: isImageUpdated)
            )
            
        case .selectImage(let imageData):
            return .just(.setProfileImage(imageData))
            
        case .updateNickname(let nickname):
            return .just(.setNickname(nickname))
            
        case .completeProfile:
            return completeProfileFlow(nickname: "", birthDate: "", image: nil, isImageUpdated: false)
            
        case .updateBirthDate(let birthDate):
            return .just(.setBirthDate(birthDate))
        case .viewWillAppear:
            return Observable.concat(
                fetchStatusAndUser(),
                fetchCoupleInfo()
            )
        case .cancleConnect:
            return cancleConnect()
        case .deleteAccount:
            return deleteAccount()
        case .logoutAccount:
            return logoutAccout()
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
            if isLoading {
                newState.errorMessage = nil
            }
        case .setSuccess:
            newState.isLoading = false
            newState.isCompleted = true
            newState.errorMessage = nil
            
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
        case .resetCompleted:
            newState.isCompleted = false
            
        case .deleteSuccess:
            newState.deleteSuccess = true
        case .setCoupleInfo(let data):
            newState.coupleInfo = data
        case .logoutSuccess:
            newState.logoutSuccess = true
        }
        
        return newState
    }
    
    private func completeProfileFlow(
        nickname: String,
        birthDate: String,
        image: Data?,
        isImageUpdated: Bool
    ) -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let result = try await self.completeProfileUseCase.execute(
                            nickname: nickname,
                            birthday: birthDate,
                            profileImage: image,
                            isImageUpdated: isImageUpdated
                        )
                        UserManager.shared.userId = result.userId
                        UserManager.shared.nickName = result.nickname
                        UserManager.shared.profileImageUrl = result.profileImageUrl
                        observer.onNext(.setUser(result))
                        observer.onNext(.setSuccess)
                        observer.onNext(.resetCompleted)
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
    
    private func fetchStatusAndUser() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                Task { @MainActor in
                    do {
                        async let statusTask = self.fetchUserStatusUseCase.execute()
                        async let userTask = self.fetchUserInfoUseCase.execute()

                        let (status, user) = try await (statusTask, userTask)

                        observer.onNext(.setUserStatus(status))
                        observer.onNext(.setUser(user))
                        observer.onNext(.setSuccess)
                        observer.onNext(.resetCompleted)
                        observer.onCompleted()
                    } catch let error as UploadImageError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError("프로필 정보를 불러오는데 실패했습니다."))
                        observer.onCompleted()
                    }
                }

                return Disposables.create()
            }
        )
    }
    
    private func fetchCoupleInfo() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            Task { @MainActor in
                do {
                    async let coupleInfoTask = self.coupleInfoUsecase.execute()

                    let couple = try await coupleInfoTask

                    observer.onNext(.setCoupleInfo(couple))
                    observer.onNext(.setSuccess)
                    observer.onNext(.resetCompleted)
                    observer.onCompleted()
                } catch let error as NetworkError {
                    observer.onNext(.setError(error.errorDescription))
                    observer.onCompleted()
                } catch {
                    observer.onNext(.setError("커플 정보를 불러오는데 실패했습니다."))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
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
                        observer.onNext(.setSuccess)
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
    
    private func deleteAccount() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        try await self.deleteUserUseCase.execute()
                        observer.onNext(.deleteSuccess)
                        observer.onNext(.setSuccess)
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("탈퇴에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
    
    private func logoutAccout() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let fcmToken = FCMTokenManager.shared.fcmToken ?? ""
                        try await self.deleteUserUseCase.execute(fcmToken: fcmToken)
                        observer.onNext(.logoutSuccess)
                        observer.onNext(.setSuccess)
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("탈퇴에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}

