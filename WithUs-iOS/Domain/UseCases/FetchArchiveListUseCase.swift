//
//  FetchArchiveListUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

protocol FetchArchiveListUseCaseProtocol {
    func execute(size: Int, cursor: String?) async throws -> ArchiveListResponse
    func execute(year: Int, month: Int) async throws -> ArchiveCalendarResponse
    func executeList(size: Int, cursor: String?) async throws -> ArchiveQuestionListResponse
    func executeQuestionDetail(coupleQuestionId: Int) async throws -> ArchiveQuestionDetailResponse
}

final class FetchArchiveListUseCase: FetchArchiveListUseCaseProtocol {
    private let archiveService: FetchArchiveListRepositoryProtocol
    
    init(archiveService: FetchArchiveListRepositoryProtocol) {
        self.archiveService = archiveService
    }
    
    func execute(size: Int, cursor: String?) async throws -> ArchiveListResponse {
        return try await archiveService.fetchArchiveList(size: size, cursor: cursor)
    }
    
    func execute(year: Int, month: Int) async throws -> ArchiveCalendarResponse {
        return try await archiveService.fetchArchiveCalendar(year: year, month: month)
    }
    
    func executeList(size: Int, cursor: String?) async throws -> ArchiveQuestionListResponse {
        return try await archiveService.fetchArchiveQuestionList(size: size, cursor: cursor)
    }
    
    func executeQuestionDetail(coupleQuestionId: Int) async throws -> ArchiveQuestionDetailResponse {
        return try await archiveService.fetchArchiveQuestionDetail(coupleQuestionId: coupleQuestionId)
    }
}
