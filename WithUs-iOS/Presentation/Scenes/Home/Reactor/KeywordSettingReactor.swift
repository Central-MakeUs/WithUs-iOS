//
//  KeywordSettingReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/30/26.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import RxRelay

protocol KeywordEventServiceProtocol {
    var event: PublishSubject<([Int], [String])> { get }
    func updateKeywords(defaultIds: [Int], customs: [String])
}

final class KeywordEventService: KeywordEventServiceProtocol {
    let event = PublishSubject<([Int], [String])>()
    
    func updateKeywords(defaultIds: [Int], customs: [String]) {
        event.onNext((defaultIds, customs))
    }
}
final class KeywordSettingReactor: Reactor {
    private let keywordService: KeywordEventServiceProtocol
    
    enum Action {
        case updateKeywords(defaultKeywordIds: [Int], customKeywords: [String])
    }
    
    enum Mutation {
        case setKeywords(defaultKeywordIds: [Int], customKeywords: [String])
        case setLoading(Bool)
        case setError(String)
        case setSuccess
    }
    
    struct State {
        var defaultKeywordIds: [Int] = []
        var customKeywords: [String] = []
        var isLoading: Bool = false
        var isCompleted: Bool = false
        var errorMessage: String?
    }
    
    let initialState = State()
    
    private let fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol
    
    init(fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol, keywordService: KeywordEventServiceProtocol) {
        self.fetchCoupleKeywordsUseCase = fetchCoupleKeywordsUseCase
        self.keywordService = keywordService
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateKeywords(defaultKeywordIds: let defaultKeywordIds, customKeywords: let customKeywords):
            return updateKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setSuccess:
            newState.isLoading = false
            newState.isCompleted = true
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            
        case .setKeywords(defaultKeywordIds: let defaultKeywordIds, customKeywords: let customKeywords):
            newState.defaultKeywordIds = defaultKeywordIds
            newState.customKeywords = customKeywords
        }
        return newState
    }
    
    private func updateKeywords(defaultKeywordIds: [Int], customKeywords: [String]) -> Observable<Mutation> {
        
        return Observable.concat(
            
            .just(.setLoading(true)),
            
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task { @MainActor in
                    do {
                        try await self.fetchCoupleKeywordsUseCase.execute(
                            defaultKeywordIds: defaultKeywordIds,
                            customKeywords: customKeywords
                        )
                        observer.onNext(.setKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords))
                        observer.onNext(.setSuccess)
                        self.keywordService.updateKeywords(
                            defaultIds: defaultKeywordIds,
                            customs: customKeywords)
                        observer.onCompleted()
                    } catch let error as NetworkError {
                        observer.onNext(.setError(error.errorDescription))
                        observer.onCompleted()
                        
                    } catch {
                        observer.onNext(.setError("키워드 변경에 실패했습니다."))
                        observer.onCompleted()
                    }
                }
                
                return Disposables.create()
            }
        )
    }
}
