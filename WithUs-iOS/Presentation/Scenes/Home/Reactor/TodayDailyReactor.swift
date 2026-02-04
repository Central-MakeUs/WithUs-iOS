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
        case selectKeyword(coupleKeywordId: Int, index: Int)
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
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return refreshKeywordsAndData()
            
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
            
        case .pokeSuccess(let result):
            newState.pokeSuccess = result
        }
        
        return newState
    }
    
    private func refreshKeywordsAndData() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let newKeywords = try await self.fetchCoupleKeywordsUseCase.execute()
                        let oldKeywords = self.currentState.keywords
                        
                        let isKeywordsChanged = !self.isKeywordsEqual(oldKeywords, newKeywords)
                        
                        observer.onNext(.setCoupleKeywords(newKeywords))
                        
                        if isKeywordsChanged {
                            if let firstKeyword = newKeywords.first,
                               let coupleKeywordId = Int(firstKeyword.id) {
                                observer.onNext(.setSelectedKeywordIndex(0))
                                let data = try await self.fetchTodayKeywordUseCase.execute(coupleKeywordId: coupleKeywordId)
                                observer.onNext(.setTodayKeyword(data))
                            }
                        } else {
                            let currentIndex = self.currentState.selectedKeywordIndex
                            if currentIndex < newKeywords.count,
                               let coupleKeywordId = Int(newKeywords[currentIndex].id) {
                                let data = try await self.fetchTodayKeywordUseCase.execute(coupleKeywordId: coupleKeywordId)
                                observer.onNext(.setTodayKeyword(data))
                            }
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
    
    private func isKeywordsEqual(_ old: [Keyword], _ new: [Keyword]) -> Bool {
        guard old.count == new.count else { return false }
        
        return zip(old, new).allSatisfy { $0.id == $1.id }
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
                            observer.onNext(.pokeSuccess(false))
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
}
