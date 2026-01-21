//
//  HomeReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Foundation
import ReactorKit

final class HomeReactor: Reactor {
    enum Action {
        case viewWillAppear
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setOnboardingStatus(OnboardingStatus)
        case setError(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var onboardingStatus: OnboardingStatus?
        var errorMessage: String?
    }
    
    let initialState: State = .init()
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    
    init(fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol) {
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            fetchUserStatus()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
        case .setOnboardingStatus(let status):
            newState.isLoading = false
            newState.errorMessage = nil
            newState.onboardingStatus = status
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            newState.onboardingStatus = nil
        }
        
        return newState
    }
    
    private func fetchUserStatus() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create{ [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let status = try await self.fetchUserStatusUseCase.execute()
                        observer.onNext(.setOnboardingStatus(status))
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("다시 접속해주세요."))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
}
