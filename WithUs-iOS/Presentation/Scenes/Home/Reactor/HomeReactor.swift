//
//  HomeReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import Foundation
import ReactorKit
import RxSwift
import UIKit

final class HomeReactor: Reactor {
    enum Action {
        case viewWillAppear
        case selectKeyword(index: Int) // 상단 탭 선택 (오늘의 질문 or 오늘의 일상)
        case selectDefaultKeyword
        case loadDailyKeyword(coupleKeywordId: Int, pageIndex: Int) // PageControl 스와이프시 특정 키워드 데이터 로드
        case uploadQuestionImage(coupleQuestionId: Int, image: UIImage)
        case uploadKeywordImage(coupleKeywordId: Int, image: UIImage)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setOnboardingStatus(OnboardingStatus)
        case setCoupleKeywords([Keyword]) // 키워드 리스트
        case setSelectedKeywordIndex(Int) // 상단 탭 인덱스
        case setCurrentDailyPageIndex(Int) // ✅ 현재 일상 페이지 인덱스
        case setTodayQuestion(TodayQuestionResponse)
        case setTodayKeyword(TodayKeywordResponse) // 특정 키워드 데이터
        case setImageUploadSuccess(String)
        case setError(String)
        case clearCurrentData
        case showDailyCoupleSetup
        case resetKeywordLoadState
    }
    
    struct State {
        var isLoading: Bool = false
        var onboardingStatus: OnboardingStatus?
        var keywords: [Keyword] = [] // 서버에서 가져온 키워드 리스트
        var selectedKeywordIndex: Int = 0 // 상단 탭 (0: 오늘의 질문, 1: 오늘의 일상)
        var currentQuestionData: TodayQuestionResponse?
        var currentKeywordData: TodayKeywordResponse? // 현재 보고 있는 키워드 데이터
        var uploadedImageUrl: String?
        var errorMessage: String?
        var shouldShowDailyCoupleSetup: Bool = false
        var hasLoadedKeywords: Bool = false // ✅ 키워드 리스트 로드 여부
        var currentDailyPageIndex: Int = 0 // ✅ 현재 보고 있는 일상 키워드 페이지 인덱스
    }
    
    let initialState: State = .init()
    
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    private let fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol
    private let fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol
    private let uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol
    private let fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol
    private let uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol
    private let keywordService: KeywordEventServiceProtocol
    
    init(
        fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol,
        fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol,
        fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol,
        uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol,
        fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol,
        uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol,
        keywordService: KeywordEventServiceProtocol) {
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
        self.fetchCoupleKeywordsUseCase = fetchCoupleKeywordsUseCase
        self.fetchTodayQuestionUseCase = fetchTodayQuestionUseCase
        self.uploadQuestionImageUseCase = uploadQuestionImageUseCase
        self.fetchTodayKeywordUseCase = fetchTodayKeywordUseCase
        self.uploadKeywordImageUseCase = uploadKeywordImageUseCase
            self.keywordService = keywordService
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let keywordResetMutation = keywordService.event
            .map { _ in Mutation.resetKeywordLoadState }
        
        return Observable.merge(mutation, keywordResetMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchUserStatus()
            
        case .selectKeyword(let index):
            let status = currentState.onboardingStatus
            
            // ✅ "오늘의 질문" 선택 (index 0)
            if index == 0 {
                return Observable.concat([
                    .just(.clearCurrentData),
                    .just(.setSelectedKeywordIndex(index)),
                    fetchTodayQuestionAsync()
                ])
            }
            
            // ✅ "오늘의 일상" 선택 (index 1)
            else {
                // needCoupleSetup 상태라면 커플 설정 UI 표시
                if status == .needCoupleSetup {
                    return Observable.concat([
                        .just(.clearCurrentData),
                        .just(.setSelectedKeywordIndex(index)),
                        .just(.showDailyCoupleSetup)
                    ])
                }
                
                // completed 상태
                else if status == .completed {
                    // ✅ 이미 키워드를 로드한 적이 있으면 현재 보던 키워드 데이터 가져오기
                    if currentState.hasLoadedKeywords {
                        let currentIndex = currentState.currentDailyPageIndex
                        guard currentIndex < currentState.keywords.count,
                              let coupleKeywordId = Int(currentState.keywords[currentIndex].id) else {
                            return Observable.concat([
                                .just(.clearCurrentData),
                                .just(.setSelectedKeywordIndex(index))
                            ])
                        }
                        
                        return Observable.concat([
                            .just(.clearCurrentData),
                            .just(.setSelectedKeywordIndex(index)),
                            fetchTodayKeywordAsync(coupleKeywordId: coupleKeywordId)
                        ])
                    }
                    // ✅ 최초 진입이면 키워드 리스트 + 첫번째 데이터 모두 가져오기
                    else {
                        return Observable.concat([
                            .just(.clearCurrentData),
                            .just(.setSelectedKeywordIndex(index)),
                            fetchCoupleKeywordsAndFirstKeywordData()
                        ])
                    }
                }
                
                return .just(.setSelectedKeywordIndex(index))
            }
            
        case .selectDefaultKeyword:
            // 초기 진입시 "오늘의 질문" 선택
            return Observable.concat([
                .just(.setSelectedKeywordIndex(0)),
                fetchTodayQuestionAsync()
            ])
            
        case .loadDailyKeyword(let coupleKeywordId, let pageIndex):
            // PageControl 스와이프시 해당 키워드 데이터 로드 + 인덱스 저장
            return Observable.concat([
                .just(.setCurrentDailyPageIndex(pageIndex)),
                fetchTodayKeywordAsync(coupleKeywordId: coupleKeywordId)
            ])
            
        case .uploadQuestionImage(let coupleQuestionId, let image):
            return uploadQuestionImageAsync(coupleQuestionId: coupleQuestionId, image: image)
            
        case .uploadKeywordImage(let coupleKeywordId, let image):
            return uploadKeywordImageAsync(coupleKeywordId: coupleKeywordId, image: image)
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
            
        case .setCoupleKeywords(let keywords):
            newState.keywords = keywords
            newState.hasLoadedKeywords = true
            
        case .setSelectedKeywordIndex(let index):
            newState.selectedKeywordIndex = index
            
        case .setCurrentDailyPageIndex(let index):
            newState.currentDailyPageIndex = index
            
        case .setTodayQuestion(let data):
            newState.currentQuestionData = data
            newState.currentKeywordData = nil
            newState.shouldShowDailyCoupleSetup = false
            
        case .setTodayKeyword(let data):
            newState.currentKeywordData = data
            newState.currentQuestionData = nil
            newState.shouldShowDailyCoupleSetup = false
            
        case .setImageUploadSuccess(let imageKey):
            newState.uploadedImageUrl = imageKey
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            
        case .clearCurrentData:
            newState.currentQuestionData = nil
            newState.currentKeywordData = nil
            newState.uploadedImageUrl = nil
            newState.errorMessage = nil
            newState.shouldShowDailyCoupleSetup = false
            
        case .showDailyCoupleSetup:
            newState.shouldShowDailyCoupleSetup = true
        case .resetKeywordLoadState:
            newState.hasLoadedKeywords = false
        }
        
        return newState
    }
    
    // MARK: - Private Methods
    
    private func fetchUserStatus() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
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
    
    private func fetchTodayQuestionAsync() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            Task {
                do {
                    let data = try await self.fetchTodayQuestionUseCase.execute()
                    observer.onNext(.setTodayQuestion(data))
                    observer.onCompleted()
                } catch {
                    observer.onNext(.setError(error.localizedDescription))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // ✅ 키워드 리스트 가져오고 + 첫 번째 키워드 데이터 로드
    private func fetchCoupleKeywordsAndFirstKeywordData() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            Task {
                do {
                    // 1. 키워드 리스트 가져오기
                    let keywords = try await self.fetchCoupleKeywordsUseCase.execute()
                    observer.onNext(.setCoupleKeywords(keywords))
                    
                    // 2. 첫 번째 키워드 데이터 로드
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
    }
    
    private func fetchTodayKeywordAsync(coupleKeywordId: Int) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
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
    }
    
    private func uploadQuestionImageAsync(coupleQuestionId: Int, image: UIImage) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let imageKey = try await self.uploadQuestionImageUseCase.execute(
                            coupleQuestionId: coupleQuestionId,
                            image: image
                        )
                        observer.onNext(.setImageUploadSuccess(imageKey))
                        
                        // 업로드 후 새로고침
                        let data = try await self.fetchTodayQuestionUseCase.execute()
                        observer.onNext(.setTodayQuestion(data))
                        observer.onCompleted()
                    } catch {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            },
            .just(.setLoading(false))
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
            },
            .just(.setLoading(false))
        ])
    }
}
