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
        case uploadError(String)
        case setMemorySummary(MemorySummaryResponse)
        case setSelectedDate(year: Int, month: Int)
        case setDetailMemory(String)
        case clearDetailMemory
        case setCoupleInfo(ProfileData)
    }

    struct State {
        var isLoading: Bool = false
        var uploadedImageUrl: String?
        var errorMessage: String?
        var uploadErrorMessage: String?
        var memorySummary: MemorySummaryResponse?
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

        case .fetchDetailMemory(let memoryType, let weekEndDate, let targetId):
            return loadDetailSummary(memoryType: memoryType, weekEndDate: weekEndDate, targetId: targetId)
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state

        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            if isLoading {
                newState.errorMessage = nil
                newState.uploadErrorMessage = nil
            }
        case .setImageUploadSuccess(let imageKey):
            newState.uploadedImageUrl = imageKey
            newState.isLoading = false
            newState.uploadErrorMessage = nil
            
        case .setError(let message):
            newState.isLoading = false
            newState.errorMessage = message

        case .setMemorySummary(let summary):
            newState.memorySummary = summary
            newState.isLoading = false

        case .setSelectedDate(let year, let month):
            newState.selectedYear = year
            newState.selectedMonth = month

        case .setDetailMemory(let memory):
            newState.detailMemory = memory

        case .clearDetailMemory:
            newState.detailMemory = nil
            newState.isLoading = false

        case .setCoupleInfo(let data):
            newState.coupleInfo = data
            
        case .uploadError(let message):
            newState.isLoading = false
            newState.uploadErrorMessage = message
        }

        return newState
    }

    private func errorMessage(from error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription
        }
        return error.localizedDescription
    }

    private func uploadImageAsync(image: UIImage, title: String) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let imageKey = try await self.memoryContentUsecase.execute(image: image, title: title)
                        observer.onNext(.setImageUploadSuccess(imageKey))
                    } catch {
                        observer.onNext(.uploadError(self.errorMessage(from: error)))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }
        ])
    }

    private func loadMemories(year: Int, month: Int) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let data = try await self.memoryContentUsecase.execute(year: year, month: month)
                        await MainActor.run {
                            observer.onNext(.setMemorySummary(data))
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(self.errorMessage(from: error)))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        ])
    }

    private func loadDetailSummary(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let imageUrl = try await self.memoryContentUsecase.execute(
                            memoryType: memoryType,
                            weekEndDate: weekEndDate,
                            targetId: targetId
                        )
                        await MainActor.run {
                            observer.onNext(.setDetailMemory(imageUrl))
                            observer.onNext(.clearDetailMemory)
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(self.errorMessage(from: error)))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        ])
    }

    private func createWeekMemoryFromUrls(imageUrls: [String], weekEndDate: String) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let fourCutImage = try await ImageGenerator.generateImage(
                            imageUrls: imageUrls,
                            dateText: weekEndDate,
                            frameColor: .white,
                            myProfileImageUrl: self.currentState.coupleInfo?.meProfile.profileImageUrl,
                            partnerProfileImageUrl: self.currentState.coupleInfo?.partnerProfile.profileImageUrl
                        )

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
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(self.errorMessage(from: error)))
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
            guard let self else { observer.onCompleted(); return Disposables.create() }
            Task {
                do {
                    let coupleInfo = try await self.coupleInfoUsecase.execute()
                    await MainActor.run {
                        observer.onNext(.setCoupleInfo(coupleInfo))
                        observer.onCompleted()
                    }
                } catch {
                    await MainActor.run {
                        observer.onNext(.setError(self.errorMessage(from: error)))
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
