//
//  MemoryReactor.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import ReactorKit
import UIKit
import RxSwift

final class MemoryReactor: Reactor {
    enum Action {
        case viewWillAppear
        case selectDate(year: Int, month: Int)
        case uploadImage(image: UIImage, title: String)
        case createWeekMemory(image: UIImage, weekEndDate: String)
        case refreshMemories
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setImageUploadSuccess(String)
        case setError(String)
        case setMemorySummary(MemorySummaryResponse)
        case setMemoriesLoading(Bool)
        case setSelectedDate(year: Int, month: Int)
    }
    
    struct State {
        var isLoading: Bool = false
        var uploadedImageUrl: String?
        var errorMessage: String?
        var memorySummary: MemorySummaryResponse?
        var isMemoriesLoading: Bool = false
        var selectedYear: Int
        var selectedMonth: Int
        
        init() {
            let now = Date()
            let calendar = Calendar.current
            self.selectedYear = calendar.component(.year, from: now)
            self.selectedMonth = calendar.component(.month, from: now)
        }
    }
    
    let initialState: State = .init()
    private let memoryContentUsecase: MemoryContentUseCaseProtocol
    
    init(memoryContentUsecase: MemoryContentUseCaseProtocol) {
        self.memoryContentUsecase = memoryContentUsecase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            // 현재 State의 선택된 년월로 로드
            return loadMemories(year: currentState.selectedYear, month: currentState.selectedMonth)
            
        case .selectDate(let year, let month):
            // 날짜 선택 후 메모리 로드
            return .concat([
                .just(.setSelectedDate(year: year, month: month)),
                loadMemories(year: year, month: month)
            ])
            
        case .refreshMemories:
            // 현재 선택된 년월로 새로고침
            return loadMemories(year: currentState.selectedYear, month: currentState.selectedMonth)
            
        case .uploadImage(let image, let title):
            return uploadImageAsync(image: image, title: title)
            
        case .createWeekMemory(let image, let weekEndDate):
            return createWeekMemoryAsync(image: image, weekEndDate: weekEndDate)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            newState.errorMessage = nil
            
        case .setImageUploadSuccess(let imageKey):
            newState.uploadedImageUrl = imageKey
            newState.isLoading = false
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message
            
        case .setMemorySummary(let summary):
            newState.memorySummary = summary
            
        case .setMemoriesLoading(let isLoading):
            newState.isMemoriesLoading = isLoading
            
        case .setSelectedDate(let year, let month):
            newState.selectedYear = year
            newState.selectedMonth = month
        }
        return newState
    }
    
    private func uploadImageAsync(image: UIImage, title: String) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let imageKey = try await self.memoryContentUsecase.execute(image: image, title: title)
                        observer.onNext(.setImageUploadSuccess(imageKey))
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
    private func loadMemories(year: Int, month: Int) -> Observable<Mutation> {
        let startLoading: Observable<Mutation> = .just(.setMemoriesLoading(true))
        
        let fetchMemories: Observable<Mutation> = Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            Task {
                do {
                    let data = try await self.memoryContentUsecase.execute(year: year, month: month)
                    await MainActor.run {
                        observer.onNext(.setMemorySummary(data))
                        observer.onNext(.setMemoriesLoading(false))
                        observer.onCompleted()
                    }
                } catch {
                    await MainActor.run {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onNext(.setMemoriesLoading(false))
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
        
        return .concat([startLoading, fetchMemories])
    }
    
    private func createWeekMemoryAsync(image: UIImage, weekEndDate: String) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let imageKey = try await self.memoryContentUsecase.execute(weekEndDate: weekEndDate, image: image)
                        observer.onNext(.setLoading(false))
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
