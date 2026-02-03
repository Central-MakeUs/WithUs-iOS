//
//  TodayDailyReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation
import ReactorKit
import RxSwift
import UIKit

final class TodayDailyReactor: Reactor {
    enum Action {
        case viewWillAppear
        case selectKeyword(coupleKeywordId: Int, index: Int)  // 키워드 탭 클릭
        case uploadKeywordImage(coupleKeywordId: Int, image: UIImage)
        case poke
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setCoupleKeywords([Keyword])
        case setSelectedKeywordIndex(Int)
        case setTodayKeyword(TodayKeywordResponse)
        case setImageUploadSuccess(String)
        case setError(String)
        case resetKeywordLoadState  // keywordService 이벤트 시 키워드 리스트 리셋
        case pokeSuccess(Bool)
    }
    
    struct State {
        var isLoading: Bool = false
        var keywords: [Keyword] = []
        var selectedKeywordIndex: Int = 0
        var currentKeywordData: TodayKeywordResponse?
        var partnerUserId: Int?
        var uploadedImageUrl: String?
        var errorMessage: String?
        var hasLoadedKeywords: Bool = false
        var pokeSuccess: Bool = false
    }
    
    let initialState: State = .init()
    
    private let fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol
    private let fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol
    private let uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol
    private let keywordService: KeywordEventServiceProtocol
    private let pokePartnerUseCase: PokePartnerUseCaseProtocol
    
    init(
        fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol,
        fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol,
        uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol,
        keywordService: KeywordEventServiceProtocol,
        pokePartnerUseCase: PokePartnerUseCaseProtocol
    ) {
        self.fetchCoupleKeywordsUseCase = fetchCoupleKeywordsUseCase
        self.fetchTodayKeywordUseCase = fetchTodayKeywordUseCase
        self.uploadKeywordImageUseCase = uploadKeywordImageUseCase
        self.keywordService = keywordService
        self.pokePartnerUseCase = pokePartnerUseCase
    }
    
    // keywordService 이벤트 발생 시 키워드 리스트 리셋 + 다시 로드
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let keywordResetMutation = keywordService.event
            .map { _ in Mutation.resetKeywordLoadState }
        
        return Observable.merge(mutation, keywordResetMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            if currentState.hasLoadedKeywords {
                let currentIndex = currentState.selectedKeywordIndex
                guard currentIndex < currentState.keywords.count,
                      let coupleKeywordId = Int(currentState.keywords[currentIndex].id) else {
                    return .empty()
                }
                return fetchTodayKeywordAsync(coupleKeywordId: coupleKeywordId)
            } else {
                return fetchCoupleKeywordsAndFirstKeywordData()
            }
            
        case .selectKeyword(let coupleKeywordId, let index):
            return Observable.concat([
                .just(.setSelectedKeywordIndex(index)),
                fetchTodayKeywordAsync(coupleKeywordId: coupleKeywordId)
            ])
            
        case .uploadKeywordImage(let coupleKeywordId, let image):
            return uploadKeywordImageAsync(coupleKeywordId: coupleKeywordId, image: image)
            
        case .poke:
            return pokePartner()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
            
        case .setCoupleKeywords(let keywords):
            newState.keywords = keywords
            newState.hasLoadedKeywords = true
            
        case .setSelectedKeywordIndex(let index):
            newState.selectedKeywordIndex = index
            
        case .setTodayKeyword(let data):
            newState.isLoading = false
            newState.currentKeywordData = data
            newState.errorMessage = nil
            if let partnerInfo = data.partnerInfo {
                newState.partnerUserId = partnerInfo.userId
            }
        case .setImageUploadSuccess(let imageKey):
            newState.uploadedImageUrl = imageKey
            newState.isLoading = false
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            
        case .resetKeywordLoadState:
            newState.hasLoadedKeywords = false
            newState.keywords = []
            newState.currentKeywordData = nil
            newState.selectedKeywordIndex = 0
        case .pokeSuccess(let result):
            newState.pokeSuccess = result
        }
        
        return newState
    }
    
    private func fetchCoupleKeywordsAndFirstKeywordData() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let keywords = try await self.fetchCoupleKeywordsUseCase.execute()
                        observer.onNext(.setCoupleKeywords(keywords))
                        
                        if let firstKeyword = keywords.first,
                           let coupleKeywordId = Int(firstKeyword.id) {
                            let data = try await self.fetchTodayKeywordUseCase.execute(coupleKeywordId: coupleKeywordId)
                            observer.onNext(.setTodayKeyword(data))
                        }
                        
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
    
    private func fetchTodayKeywordAsync(coupleKeywordId: Int) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let data = try await self.fetchTodayKeywordUseCase.execute(coupleKeywordId: coupleKeywordId)
                        observer.onNext(.setTodayKeyword(data))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
    
    private func uploadKeywordImageAsync(coupleKeywordId: Int, image: UIImage) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let imageKey = try await self.uploadKeywordImageUseCase.execute(
                            coupleKeywordId: coupleKeywordId,
                            image: image
                        )
                        observer.onNext(.setImageUploadSuccess(imageKey))
                        
                        // 업로드 후 새로고침
                        let data = try await self.fetchTodayKeywordUseCase.execute(coupleKeywordId: coupleKeywordId)
                        observer.onNext(.setTodayKeyword(data))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
    
    private func pokePartner() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        if let partnerUserId = self.currentState.partnerUserId {
                            try await self.pokePartnerUseCase.execute(id: partnerUserId)
                            observer.onNext(.pokeSuccess(true))
                        }
                        observer.onCompleted()
                        observer.onNext(.pokeSuccess(false))
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        ])
    }
}
