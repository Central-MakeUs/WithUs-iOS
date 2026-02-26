//
//  NotiCenterReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/26/26.
//

import Foundation
import ReactorKit

final class NotiCenterReactor: Reactor {
    enum Action {
        case loadInitialData
        case loadMoreData
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setError(String)
        case setNextCursor(String?)
        case setHasNext(Bool)
        case setNoti([NotiCenterItem])
        case appendNoti([NotiCenterItem])
    }
    
    struct State {
        var isLoading: Bool = false
        var errorMessage: String?
        var nextCursor: String?
        var hasNext: Bool = false
        var noti: [NotiCenterItem] = []
    }
    
    let initialState: State = .init()
    
    private let usecase: NotiCenterUsecaseProtocol
    
    init(usecase: NotiCenterUsecaseProtocol) {
        self.usecase = usecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .loadInitialData:
            return loadNoti(cursor: nil, isRefresh: true)
        case .loadMoreData:
            guard currentState.hasNext else { return .empty() }
            return loadNoti(cursor: currentState.nextCursor, isRefresh: false)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
            
        case .setNoti(let noti):
            newState.noti = noti
            
        case .appendNoti(let noti):
            newState.noti.append(contentsOf: noti)
            
        case .setNextCursor(let cursor):
            newState.nextCursor = cursor
            
        case .setHasNext(let hasNext):
            newState.hasNext = hasNext
        case .setError(let message):
            newState.errorMessage = message
            newState.isLoading = false
        }
        return newState
    }
    
    private func loadNoti(cursor: String?, isRefresh: Bool) -> Observable<Mutation> {
        return .concat(
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let data = try await self.usecase.execute(size: 20, cursor: cursor)
                        await MainActor.run {
                            observer.onNext(isRefresh ? .setNoti(data.notifications) : .appendNoti(data.notifications))
                            observer.onNext(.setNextCursor(data.nextCursor))
                            observer.onNext(.setHasNext(data.hasNext))
                            observer.onNext(.setLoading(false))
                            observer.onCompleted()
                        }
                    } catch let error as NetworkError {
                        await MainActor.run {
                            observer.onNext(.setError(error.errorDescription))
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(error.localizedDescription))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        )
    }
}
