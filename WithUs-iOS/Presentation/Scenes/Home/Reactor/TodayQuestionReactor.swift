//
//  TodayQuestionReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation
import ReactorKit
import RxSwift
import UIKit

final class TodayQuestionReactor: Reactor {
    enum Action {
        case viewWillAppear
        case uploadQuestionImage(coupleQuestionId: Int, image: UIImage)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setTodayQuestion(TodayQuestionResponse)
        case setImageUploadSuccess(String)
        case setError(String)
    }
    
    struct State {
        var isLoading: Bool = false
        var currentQuestionData: TodayQuestionResponse?
        var uploadedImageUrl: String?
        var errorMessage: String?
    }
    
    let initialState: State = .init()
    
    private let fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol
    private let uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol
    
    init(
        fetchTodayQuestionUseCase: FetchTodayQuestionUseCaseProtocol,
        uploadQuestionImageUseCase: UploadQuestionImageUseCaseProtocol
    ) {
        self.fetchTodayQuestionUseCase = fetchTodayQuestionUseCase
        self.uploadQuestionImageUseCase = uploadQuestionImageUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchTodayQuestionAsync()
            
        case .uploadQuestionImage(let coupleQuestionId, let image):
            return uploadQuestionImageAsync(coupleQuestionId: coupleQuestionId, image: image)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
            
        case .setTodayQuestion(let data):
            newState.isLoading = false
            newState.currentQuestionData = data
            newState.errorMessage = nil
            
        case .setImageUploadSuccess(let imageKey):
            newState.uploadedImageUrl = imageKey
            newState.isLoading = false
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func fetchTodayQuestionAsync() -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
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
        ])
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
            }
        ])
    }
}
