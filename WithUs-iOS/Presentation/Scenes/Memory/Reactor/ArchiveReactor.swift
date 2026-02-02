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
    
    enum Action {
        case viewDidLoad
        case selectTab(Int)
        case loadMoreRecent
        case loadCalendarMonth(year: Int, month: Int)
    }
    
    enum Mutation {
        case setSelectedTab(Int)
        case setRecentPhotos([ArchivePhotoViewModel])
        case appendRecentPhotos([ArchivePhotoViewModel])
        case setNextCursor(String?)
        case setHasNext(Bool)
        case setLoading(Bool)
        case setError(String)
        case appendCalendarData(ArchiveCalendarResponse)
        case setJoinDate(Date?)
    }
    
    struct State {
        var selectedTab: Int = 0
        var recentPhotos: [ArchivePhotoViewModel] = []
        var nextCursor: String?
        var hasNext: Bool = false
        var isLoading: Bool = false
        var errorMessage: String?
        var calendarDataList: [ArchiveCalendarResponse] = []
        var joinDate: Date?
    }
    
    let initialState = State()
    private let fetchArchiveListUseCase: FetchArchiveListUseCaseProtocol
    
    init(fetchArchiveListUseCase: FetchArchiveListUseCaseProtocol) {
        self.fetchArchiveListUseCase = fetchArchiveListUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                loadJoinDate(),
                loadRecentPhotos(cursor: nil, isRefresh: true)
            ])
            
        case .selectTab(let index):
            return .just(.setSelectedTab(index))
            
        case .loadMoreRecent:
            guard !currentState.isLoading, currentState.hasNext else {
                return .empty()
            }
            return loadRecentPhotos(cursor: currentState.nextCursor, isRefresh: false)
            
        case .loadCalendarMonth(let year, let month):
            return loadCalendarData(year: year, month: month)
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
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
            
        case .appendCalendarData(let data):
            if !newState.calendarDataList.contains(where: {
                $0.year == data.year && $0.month == data.month
            }) {
                newState.calendarDataList.append(data)
            }
            
        case .setJoinDate(let date):
            newState.joinDate = date
        }
        
        return newState
    }
    
    
    private func loadRecentPhotos(cursor: String?, isRefresh: Bool) -> Observable<Mutation> {
        let startLoading: Observable<Mutation> = .just(.setLoading(true))
        
        let fetchPhotos: Observable<Mutation> = Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            Task {
                do {
                    let data = try await self.fetchArchiveListUseCase.execute(size: 20, cursor: cursor)
                    
                    let viewModels = data.archiveList.flatMap { ArchivePhotoViewModel.from($0) }
                    
                    await MainActor.run {
                        if isRefresh {
                            observer.onNext(.setRecentPhotos(viewModels))
                        } else {
                            observer.onNext(.appendRecentPhotos(viewModels))
                        }
                        observer.onNext(.setNextCursor(data.nextCursor))
                        observer.onNext(.setHasNext(data.hasNext))
                        observer.onNext(.setLoading(false))
                        observer.onCompleted()
                    }
                } catch {
                    await MainActor.run {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onNext(.setLoading(false))
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
        
        return .concat([startLoading, fetchPhotos])
    }
    
    private func loadJoinDate() -> Observable<Mutation> {
        // TODO: 실제 UseCase에서 가입일 가져오기
        // let joinDate = try await fetchUserInfoUseCase.getJoinDate()
        return .just(.setJoinDate(nil)) // 임시로 nil 반환
    }
    
    private func loadCalendarData(year: Int, month: Int) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            Task {
                do {
                    let data = try await self.fetchArchiveListUseCase.execute(year: year, month: month)
                    
                    await MainActor.run {
                        observer.onNext(.appendCalendarData(data))
                        observer.onCompleted()
                    }
                } catch {
                    await MainActor.run {
                        observer.onNext(.setError(error.localizedDescription))
                        observer.onCompleted()
                    }
                }
            }
            
            return Disposables.create()
        }
    }
}
