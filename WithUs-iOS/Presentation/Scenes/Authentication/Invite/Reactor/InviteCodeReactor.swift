//
//  InviteCodeReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import ReactorKit

final class InviteCodeReactor: Reactor {
    enum Action {
        case getInvitationCode
    }
    
    enum Mutation {
        case setInvitationCode(String)
        case setLoading(Bool)
        case setSuccess
        case setError(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var isCompleted: Bool = false
        var errorMessage: String?
        var invitationCode: String?
    }
    
    let initialState: State = State()
    private let getInvitationUseCase: GetInvitationUseCaseProtocol
    
    init(getInvitationUseCase: GetInvitationUseCaseProtocol) {
        self.getInvitationUseCase = getInvitationUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .getInvitationCode:
            return getInvitationCode()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setInvitationCode(let code):
            newState.invitationCode = code
            
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
    
    private func getInvitationCode() -> Observable<Mutation> {
        return Observable.concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        let result = try await self.getInvitationUseCase.execute()
                        
                        print("✅ 초대코드 받아오기 완료")
                        print("   code: \(result.invitationCode)")
                        observer.onNext(.setInvitationCode(result.invitationCode))
                        observer.onNext(.setSuccess)
                        observer.onCompleted()
                    } catch let error as InvitationCodeError {
                        observer.onNext(.setError(error.message))
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError("초대 코드 받아오기 중 오류가 발생했습니다. 다시 시도해 주세요."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}
