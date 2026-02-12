//
//  ArchiveReactor.swift
//  WithUs-iOS
//
//  Created on 2/2/26.
//

import Foundation
import ReactorKit
import RxSwift

final class ArchiveReactor: Reactor {
    enum Action: Hashable {
        case viewDidLoad
        case selectTab(Int)
        case loadMoreRecent
        case loadCalendarMonth(year: Int, month: Int)
        case loadMoreQuestions
        case fetchQuestionDetail(coupleQuestionId: Int)
        case fetchPhotoDetail(date: String, targetId: Int?, targetType: String?)
    }
    
    enum Mutation {
        case setSelectedTab(Int)
        case setRecentPhotos([ArchivePhotoViewModel])
        case appendRecentPhotos([ArchivePhotoViewModel])
        case setNextCursor(String?)
        case setHasNext(Bool)
        case setError(String)
        case appendCalendarData(ArchiveCalendarResponse)
        case setJoinDate(Date?)
        case setQuestions([ArchiveQuestionItem])
        case appendQuestions([ArchiveQuestionItem])
        case setQuestionNextCursor(String?)
        case setQuestionHasNext(Bool)
        case setQuestionDetail(ArchiveQuestionDetailResponse?)
        case setPhotoDetail(ArchivePhotoDetailResponse?)
        case setLoading(Action, Bool)
    }
    
    struct State {
        var selectedTab: Int = 0
        var recentPhotos: [ArchivePhotoViewModel] = []
        var nextCursor: String?
        var hasNext: Bool = false
        var errorMessage: String?
        var calendarDataList: [ArchiveCalendarResponse] = []
        var joinDate: Date?
        var questions: [ArchiveQuestionItem] = []
        var questionNextCursor: String?
        var questionHasNext: Bool = false
        var questionDetail: ArchiveQuestionDetailResponse?
        var photoDetail: ArchivePhotoDetailResponse?
        var loadingActions: Set<Action> = []
        
        var isInitialLoading: Bool {
            loadingActions.contains(.viewDidLoad)
        }
        
        var isAllDataEmpty: Bool {
            !loadingActions.contains(.viewDidLoad) && recentPhotos.isEmpty && questions.isEmpty
        }
    }
    
    let initialState = State()
    private let fetchArchiveListUseCase: FetchArchiveListUseCaseProtocol
    
    init(fetchArchiveListUseCase: FetchArchiveListUseCaseProtocol) {
        self.fetchArchiveListUseCase = fetchArchiveListUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return loadInitialData()
        case .selectTab(let index):
            return .just(.setSelectedTab(index))
            
        case .loadMoreRecent:
            guard !currentState.loadingActions.contains(.loadMoreRecent),
                  currentState.hasNext else { return .empty() }
            return loadRecentPhotos(cursor: currentState.nextCursor, isRefresh: false)
            
        case .loadCalendarMonth(let year, let month):
            return loadCalendarData(year: year, month: month)
            
        case .loadMoreQuestions:
            guard !currentState.loadingActions.contains(.loadMoreQuestions),
                  currentState.questionHasNext else { return .empty() }
            return loadQuestionList(cursor: currentState.questionNextCursor, isRefresh: false)
            
        case .fetchQuestionDetail(let coupleQuestionId):
            return fetchQuestionDetail(coupleQuestionId: coupleQuestionId)
            
        case .fetchPhotoDetail(let date, let targetId, let targetType):
            return fetchPhotoDetail(date: date, targetId: targetId, targetType: targetType)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedTab(let index):
            newState.selectedTab = index
        case .setRecentPhotos(let photos):
            newState.recentPhotos = photos
        case .appendRecentPhotos(let photos):
            newState.recentPhotos.append(contentsOf: photos)
        case .setNextCursor(let cursor):
            newState.nextCursor = cursor
        case .setHasNext(let hasNext):
            newState.hasNext = hasNext
        case .setLoading(let action, let isLoading):
            if isLoading {
                newState.loadingActions.insert(action)
            } else {
                newState.loadingActions.remove(action)
            }
        case .setError(let message):
            newState.errorMessage = message
        case .appendCalendarData(let data):
            if !newState.calendarDataList.contains(where: { $0.year == data.year && $0.month == data.month }) {
                newState.calendarDataList.append(data)
            }
        case .setJoinDate(let date):
            newState.joinDate = date
        case .setQuestions(let questions):
            newState.questions = questions
        case .appendQuestions(let questions):
            newState.questions.append(contentsOf: questions)
        case .setQuestionNextCursor(let cursor):
            newState.questionNextCursor = cursor
        case .setQuestionHasNext(let hasNext):
            newState.questionHasNext = hasNext
        case .setQuestionDetail(let response):
            newState.questionDetail = response
        case .setPhotoDetail(let response):
            newState.photoDetail = response
        }
        
        return newState
    }
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        return mutation.flatMap { mutation -> Observable<Mutation> in
            switch mutation {
            case .setQuestionDetail(let detail) where detail != nil:
                return .concat(.just(mutation), .just(.setQuestionDetail(nil)))
            case .setPhotoDetail(let detail) where detail != nil:
                return .concat(.just(mutation), .just(.setPhotoDetail(nil)))
            default:
                return .just(mutation)
            }
        }
    }
    
    private func errorMessage(from error: Error) -> String {
        if let networkError = error as? NetworkError {
            return networkError.errorDescription
        }
        return error.localizedDescription
    }
    
    private func loadJoinDateAsync() async -> Date {
        if let joinDate = UserManager.shared.joinDate {
            return joinDate
        }
        
        let components = DateComponents(year: 2025, month: 12, day: 1)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private func loadInitialData() -> Observable<Mutation> {
        let loadTasks: Observable<Mutation> = Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            Task {
                let joinDate = await self.loadJoinDateAsync()
                await MainActor.run {
                    observer.onNext(.setJoinDate(joinDate))
                }
                
                async let recentResult = self.loadRecentPhotosAsync(cursor: nil)
                async let questionsResult = self.loadQuestionsAsync(cursor: nil)
                
                let (recentData, questionsData) = await (recentResult, questionsResult)
                
                await MainActor.run {
                    if let recentData = recentData {
                        observer.onNext(.setRecentPhotos(recentData.photos))
                        observer.onNext(.setNextCursor(recentData.nextCursor))
                        observer.onNext(.setHasNext(recentData.hasNext))
                    }
                    
                    if let questionsData = questionsData {
                        observer.onNext(.setQuestions(questionsData.questions))
                        observer.onNext(.setQuestionNextCursor(questionsData.nextCursor))
                        observer.onNext(.setQuestionHasNext(questionsData.hasNext))
                    }
                    
                    observer.onNext(.setLoading(.viewDidLoad, false))
                    observer.onCompleted()
                }
            }
            
            return Disposables.create()
        }
        
        return .concat([
            .just(.setLoading(.viewDidLoad, true)),
            loadTasks
        ])
    }
    
    private func loadRecentPhotosAsync(cursor: String?) async -> (photos: [ArchivePhotoViewModel], nextCursor: String?, hasNext: Bool)? {
        do {
            let data = try await fetchArchiveListUseCase.execute(size: 20, cursor: cursor)
            let viewModels = data.archiveList.flatMap { ArchivePhotoViewModel.from($0) }
            return (viewModels, data.nextCursor, data.hasNext)
        } catch {
            print("❌ Recent Photos 로드 실패: \(errorMessage(from: error))")
            return nil
        }
    }
    
    private func loadQuestionsAsync(cursor: String?) async -> (questions: [ArchiveQuestionItem], nextCursor: String?, hasNext: Bool)? {
        do {
            let data = try await fetchArchiveListUseCase.executeList(size: 20, cursor: cursor)
            return (data.questionList, data.nextCursor, data.hasNext)
        } catch {
            print("❌ Questions 로드 실패: \(errorMessage(from: error))")
            return nil
        }
    }
    
    private func loadRecentPhotos(cursor: String?, isRefresh: Bool) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(.loadMoreRecent, true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let data = try await self.fetchArchiveListUseCase.execute(size: 20, cursor: cursor)
                        let viewModels = data.archiveList.flatMap { ArchivePhotoViewModel.from($0) }
                        await MainActor.run {
                            observer.onNext(isRefresh ? .setRecentPhotos(viewModels) : .appendRecentPhotos(viewModels))
                            observer.onNext(.setNextCursor(data.nextCursor))
                            observer.onNext(.setHasNext(data.hasNext))
                            observer.onNext(.setLoading(.loadMoreRecent, false))
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(self.errorMessage(from: error)))
                            observer.onNext(.setLoading(.loadMoreRecent, false))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        ])
    }
    
    private func loadCalendarData(year: Int, month: Int) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else { observer.onCompleted(); return Disposables.create() }
            Task {
                do {
                    let data = try await self.fetchArchiveListUseCase.execute(year: year, month: month)
                    await MainActor.run {
                        observer.onNext(.appendCalendarData(data))
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
    
    private func loadQuestionList(cursor: String?, isRefresh: Bool) -> Observable<Mutation> {
        return .concat([
            .just(.setLoading(.loadMoreQuestions, true)),
            Observable.create { [weak self] observer in
                guard let self else { observer.onCompleted(); return Disposables.create() }
                Task {
                    do {
                        let data = try await self.fetchArchiveListUseCase.executeList(size: 20, cursor: cursor)
                        await MainActor.run {
                            observer.onNext(isRefresh ? .setQuestions(data.questionList) : .appendQuestions(data.questionList))
                            observer.onNext(.setQuestionNextCursor(data.nextCursor))
                            observer.onNext(.setQuestionHasNext(data.hasNext))
                            observer.onNext(.setLoading(.loadMoreQuestions, false))
                            observer.onCompleted()
                        }
                    } catch {
                        await MainActor.run {
                            observer.onNext(.setError(self.errorMessage(from: error)))
                            observer.onNext(.setLoading(.loadMoreQuestions, false))
                            observer.onCompleted()
                        }
                    }
                }
                return Disposables.create()
            }
        ])
    }
    
    private func fetchQuestionDetail(coupleQuestionId: Int) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else { observer.onCompleted(); return Disposables.create() }
            Task {
                do {
                    let data = try await self.fetchArchiveListUseCase.executeQuestionDetail(coupleQuestionId: coupleQuestionId)
                    await MainActor.run {
                        observer.onNext(.setQuestionDetail(data))
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
    
    private func fetchPhotoDetail(date: String, targetId: Int?, targetType: String?) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self else { observer.onCompleted(); return Disposables.create() }
            Task {
                do {
                    let data = try await self.fetchArchiveListUseCase.executePhotoDetail(
                        date: date,
                        targetId: targetId,
                        targetType: targetType
                    )
                    await MainActor.run {
                        observer.onNext(.setPhotoDetail(data))
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
