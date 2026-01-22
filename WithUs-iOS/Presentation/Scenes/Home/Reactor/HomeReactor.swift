//
//  HomeReactor.swift (완전 버전)
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
        case fetchCoupleKeywords
        case selectKeyword(index: Int)
        case uploadQuestionImage(coupleQuestionId: Int, image: UIImage)
        case uploadKeywordImage(coupleKeywordId: Int, image: UIImage)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setOnboardingStatus(OnboardingStatus)
        case setCoupleKeywords([Keyword])
        case setSelectedKeywordIndex(Int)
        case setTodayQuestion(TodayQuestionResponse)
        case setTodayKeyword(TodayKeywordResponse)
        case setImageUploadSuccess(String)
        case setError(String)
        case clearCurrentData  // ✅ 추가
    }
    
    struct State {
        var isLoading: Bool = false
        var onboardingStatus: OnboardingStatus?
        var keywords: [Keyword] = []
        var selectedKeywordIndex: Int = 0
        var currentQuestionData: TodayQuestionResponse?
        var currentKeywordData: TodayKeywordResponse?
        var uploadedImageUrl: String?
        var errorMessage: String?
    }
    
    let initialState: State = .init()
    
    // Use Cases
    private let fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol
    private let fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol
    private let fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol
    private let uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol
    private let fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol
    private let uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol
    
    init(
        fetchUserStatusUseCase: FetchUserStatusUseCaseProtocol,
        fetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol,
        fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol,
        uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol,
        fetchTodayKeywordUseCase: FetchTodayKeywordUseCaseProtocol,
        uploadKeywordImageUseCase: UploadKeywordImageUseCaseProtocol
    ) {
        self.fetchUserStatusUseCase = fetchUserStatusUseCase
        self.fetchCoupleKeywordsUseCase = fetchCoupleKeywordsUseCase
        self.fetchTodayQuestionUseCase = fetchTodayQuestionUseCase
        self.uploadQuestionImageUseCase = uploadQuestionImageUseCase
        self.fetchTodayKeywordUseCase = fetchTodayKeywordUseCase
        self.uploadKeywordImageUseCase = uploadKeywordImageUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchUserStatus()
            
        case .fetchCoupleKeywords:
            return fetchCoupleKeywordsAsync()
            
        case .selectKeyword(let index):
            let keyword = currentState.keywords[index]
            
            if keyword.id == "today_question" {
                return Observable.concat([
                    .just(.clearCurrentData),  // ✅ 먼저 이전 데이터 클리어
                    .just(.setSelectedKeywordIndex(index)),
                    fetchTodayQuestionAsync()
                ])
            } else {
                guard let coupleKeywordId = Int(keyword.id) else {
                    return .just(.setError("Invalid keyword ID"))
                }
                
                return Observable.concat([
                    .just(.clearCurrentData),  // ✅ 먼저 이전 데이터 클리어
                    .just(.setSelectedKeywordIndex(index)),
                    fetchTodayKeywordAsync(coupleKeywordId: coupleKeywordId)
                ])
            }
            
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
            let todayQuestion = Keyword(
                id: "today_question",
                text: "오늘의 질문",
                displayOrder: 0
            )
            newState.keywords = [todayQuestion] + keywords
            
        case .setSelectedKeywordIndex(let index):
            newState.selectedKeywordIndex = index
            
        case .setTodayQuestion(let data):
            newState.currentQuestionData = data
            newState.currentKeywordData = nil
            
        case .setTodayKeyword(let data):
            newState.currentKeywordData = data
            newState.currentQuestionData = nil
            
        case .setImageUploadSuccess(let accessUrl):
            newState.uploadedImageUrl = accessUrl
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            
        case .clearCurrentData:  // ✅ 추가
            newState.currentQuestionData = nil
            newState.currentKeywordData = nil
            newState.uploadedImageUrl = nil
            newState.errorMessage = nil
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
    
    private func fetchCoupleKeywordsAsync() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            Task {
                do {
                    let keywords = try await self.fetchCoupleKeywordsUseCase.execute()
                    observer.onNext(.setCoupleKeywords(keywords))
                    observer.onCompleted()
                } catch {
                    observer.onNext(.setError(error.localizedDescription))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
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
                        let accessUrl = try await self.uploadQuestionImageUseCase.execute(
                            coupleQuestionId: coupleQuestionId,
                            image: image
                        )
                        observer.onNext(.setImageUploadSuccess(accessUrl))
                        
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
                        let accessUrl = try await self.uploadKeywordImageUseCase.execute(
                            coupleKeywordId: coupleKeywordId,
                            image: image
                        )
                        observer.onNext(.setImageUploadSuccess(accessUrl))
                        
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
