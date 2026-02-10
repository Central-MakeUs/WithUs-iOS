//
//  InviteInputCodeReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import ReactorKit
import RxSwift

final class InviteInputCodeReactor: Reactor {
    enum Action {
        case verifyCode(String)
        case acceptInvite(String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setSuccess
        case setError(String?)
        case verifiedCode(VerifyCodePreviewResult)
        case acceptedInvite(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var isCompleted: Bool = false
        var errorMessage: String?
        var previewData: VerifyCodePreviewResult?
        var coupleId: String?
    }
    
    let initialState: State = State()
    private let usecase: VerifyCodePreviewUseCase
    
    init(usecase: VerifyCodePreviewUseCase) {
        self.usecase = usecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .verifyCode(let code):
            return verifyCode(code)
        case .acceptInvite(let code):
            return acceptInvite(code)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            if isLoading {
                newState.errorMessage = nil
            }
        case .setSuccess:
            newState.isLoading = false
            newState.isCompleted = true
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            newState.isCompleted = false
        case .verifiedCode(let preview):
            newState.previewData = preview
        case .acceptedInvite(let id):
            newState.coupleId = id
        }
        return newState
    }
    
    private func acceptInvite(_ code: String) -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let result = try await self.usecase.executeAccept(inviteCode: code)
                        print("✅ couple id 받아오기 완료")
                        observer.onNext(.setSuccess)
                        observer.onNext(.acceptedInvite(result.coupleId))
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onNext(.setError(nil))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError("연결에 실패했습니다."))
                        observer.onNext(.setError(nil))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
    
    private func verifyCode(_ code: String) -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        
                        let result = try await self.usecase.executeVerfy(inviteCode: code)
                        
                        print("✅ 초대 코드 verify 받아오기 완료")
                        print("   senderName: \(result.senderName)")
                        print("   myName: \(result.myName)")
                        print("   invitationCode: \(result.inviteCode)")
                        
                        if code == result.inviteCode {
                            observer.onNext(.setSuccess)
                            observer.onNext(.verifiedCode(result))
                        } else {
                            observer.onNext(.setError("초대코드를 다시 확인해주세요."))
                            observer.onNext(.setError(nil))
                        }
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onNext(.setError(nil))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError("인증실패했습니다. 다시 시도해 주세요."))
                        observer.onNext(.setError(nil))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}

