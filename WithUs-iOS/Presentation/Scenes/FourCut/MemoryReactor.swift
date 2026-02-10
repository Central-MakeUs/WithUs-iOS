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
        case createWeekMemory(imageUrls: [String], weekEndDate: String)
        case refreshMemories
        case fetchDetailMemory(memoryType: MemoryType, weekEndDate: String?, targetId: Int?)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setImageUploadSuccess(String)
        case setError(String)
        case setMemorySummary(MemorySummaryResponse)
        case setMemoriesLoading(Bool)
        case setSelectedDate(year: Int, month: Int)
        case setWeekMemoryCreating(Bool)
        case setDetailMemory(String)
        case clearDetailMemory
        case setCoupleInfo(ProfileData)
    }
    
    struct State {
        var isLoading: Bool = false
        var uploadedImageUrl: String?
        var errorMessage: String?
        var memorySummary: MemorySummaryResponse?
        var isMemoriesLoading: Bool = false
        var isWeekMemoryCreating: Bool = false
        var selectedYear: Int
        var selectedMonth: Int
        var detailMemory: String?
        var coupleInfo: ProfileData?
        
        init() {
            let now = Date()
            let calendar = Calendar.current
            self.selectedYear = calendar.component(.year, from: now)
            self.selectedMonth = calendar.component(.month, from: now)
        }
    }
    
    let initialState: State = .init()
    private let memoryContentUsecase: MemoryContentUseCaseProtocol
    private let coupleInfoUsecase: CoupleInfoUsecaseProtocol
    
    init(memoryContentUsecase: MemoryContentUseCaseProtocol, coupleInfoUseCase: CoupleInfoUsecaseProtocol) {
        self.memoryContentUsecase = memoryContentUsecase
        self.coupleInfoUsecase = coupleInfoUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return .concat([
                loadMemories(year: currentState.selectedYear, month: currentState.selectedMonth),
                loadCoupleInfo()
            ])
            
        case .selectDate(let year, let month):
            return .concat([
                .just(.setSelectedDate(year: year, month: month)),
                loadMemories(year: year, month: month)
            ])
            
        case .refreshMemories:
            return loadMemories(year: currentState.selectedYear, month: currentState.selectedMonth)
            
        case .uploadImage(let image, let title):
            return uploadImageAsync(image: image, title: title)
            
        case .createWeekMemory(let imageUrls, let weekEndDate):
            return createWeekMemoryFromUrls(imageUrls: imageUrls, weekEndDate: weekEndDate)
        case .fetchDetailMemory(memoryType: let memoryType, weekEndDate: let weekEndDate, targetId: let targetId):
            return loadDetailSummary(memoryType: memoryType, weekEndDate: weekEndDate, targetId: targetId)
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
            
        case .setWeekMemoryCreating(let isCreating):
            newState.isWeekMemoryCreating = isCreating
            
        case .setDetailMemory(let memory):
            newState.detailMemory = memory
            
        case .clearDetailMemory:
            newState.detailMemory = nil
            
        case .setCoupleInfo(let data):
            newState.coupleInfo = data
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
//                 let data = try await self.memoryContentUsecase.execute(year: year, month: month)
                let data = self.createTestData()
                await MainActor.run {
                    observer.onNext(.setMemorySummary(data))
                    observer.onNext(.setMemoriesLoading(false))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
        
        return .concat([startLoading, fetchMemories])
    }
    
    private func loadDetailSummary(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) -> Observable<Mutation> {
        return Observable.concat(
[
            .just(.setMemoriesLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let imageUrl = try await self.memoryContentUsecase.execute(
                            memoryType: memoryType,
                            weekEndDate: weekEndDate,
                            targetId: targetId
                        )
                        
                        await MainActor.run {
                            observer.onNext(.setDetailMemory(imageUrl))
                            observer.onNext(.setMemoriesLoading(false))
                            observer.onNext(.clearDetailMemory)
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
        ]
)
    }
    
    private func createWeekMemoryFromUrls(imageUrls: [String], weekEndDate: String) -> Observable<Mutation> {
        return Observable.concat([
            .just(.setWeekMemoryCreating(true)),
            Observable.create { [weak self] observer in
                guard let self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                
                Task {
                    do {
                        let fourCutImage = try await ImageGenerator.generateImage(
                            imageUrls: imageUrls,
                            dateText: weekEndDate,
                            frameColor: .white,
                            myProfileImageUrl: self.currentState.coupleInfo?.meProfile.profileImageUrl,
                            partnerProfileImageUrl: self.currentState.coupleInfo?.partnerProfile.profileImageUrl
                        )
                        UIImageWriteToSavedPhotosAlbum(fourCutImage, nil, nil, nil)
                        
                        let _ = try await self.memoryContentUsecase.execute(
                            weekEndDate: weekEndDate,
                            image: fourCutImage
                        )
                        
                        let refreshedData = try await self.memoryContentUsecase.execute(
                            year: self.currentState.selectedYear,
                            month: self.currentState.selectedMonth
                        )
                        
                        await MainActor.run {
                            observer.onNext(.setMemorySummary(refreshedData))
                            observer.onNext(.setWeekMemoryCreating(false))
                            observer.onCompleted()
                        }
                        
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(error.localizedDescription))
                            observer.onNext(.setWeekMemoryCreating(false))
                            observer.onCompleted()
                        }
                    }
                }
                
                return Disposables.create()
            }
        ])
    }
    
    private func loadCoupleInfo() -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else {
                observer.onCompleted()
                return Disposables.create()
            }
            
            Task {
                do {
                    let coupleInfo = try await self.coupleInfoUsecase.execute()
                    
                    await MainActor.run {
                        observer.onNext(.setCoupleInfo(coupleInfo))
                        observer.onCompleted()
                    }
                    
                } catch {
                    await MainActor.run {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onNext(.setWeekMemoryCreating(false))
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func createTestData() -> MemorySummaryResponse {
        let needCreateMemory = WeekMemorySummary(
            memoryType: .weekMemory,
            title: "4월 2주 (03.29~04.04)",
            customMemoryId: nil,
            weekEndDate: "2026-01-31",
            status: .needCreate,
            needCreateImageUrls: [
                "https://picsum.photos/500/500?random=1",
                "https://picsum.photos/500/500?random=2",
                "https://picsum.photos/500/500?random=3",
                "https://picsum.photos/500/500?random=4",
                "https://picsum.photos/500/500?random=5",
                "https://picsum.photos/500/500?random=6",
                "https://picsum.photos/500/500?random=7",
                "https://picsum.photos/500/500?random=8",
                "https://picsum.photos/500/500?random=9",
                "https://picsum.photos/500/500?random=10",
                "https://picsum.photos/500/500?random=11",
                "https://picsum.photos/500/500?random=12"
            ],
            createdImageUrl: nil,
            createdAt: "2026-04-04T23:59:99.999Z"
        )
        
        let unavailableMemory = WeekMemorySummary(
            memoryType: .weekMemory,
            title: "4월 1주 (03.22~03.28)",
            customMemoryId: nil,
            weekEndDate: "2026-03-28",
            status: .unavailable,
            needCreateImageUrls: nil,
            createdImageUrl: nil,
            createdAt: "2026-03-28T23:59:99.999Z"
        )
        
        let createdWeekMemory = WeekMemorySummary(
            memoryType: .weekMemory,
            title: "3월 4주 (03.15~03.21)",
            customMemoryId: nil,
            weekEndDate: "2026-03-21",
            status: .created,
            needCreateImageUrls: nil,
            createdImageUrl: "https://picsum.photos/500/500?random=12",
            createdAt: "2026-03-21T23:59:99.999Z"
        )
        
        let createdCustomMemory = WeekMemorySummary(
            memoryType: .customMemory,
            title: "제주도 여행",
            customMemoryId: 13,
            weekEndDate: "2026-03-14",
            status: .created,
            needCreateImageUrls: nil,
            createdImageUrl: "https://s3.withus.com/guides/pose3.png",
            createdAt: "2026-03-14T23:59:99.999Z"
        )
        
        return MemorySummaryResponse(
            monthKey: 202602, weekMemorySummaries: [
                needCreateMemory,
                unavailableMemory,
                createdWeekMemory,
                createdCustomMemory
            ]
        )
    }
}
