//
//  FetchArchiveListUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

protocol FetchArchiveListUseCaseProtocol {
    func execute(size: Int, cursor: String?) async throws -> ArchiveListResponse
}

final class FetchArchiveListUseCase: FetchArchiveListUseCaseProtocol {
    private let archiveService: FetchArchiveListRepositoryProtocol
    
    init(archiveService: FetchArchiveListRepositoryProtocol) {
        self.archiveService = archiveService
    }
    
    func execute(size: Int, cursor: String?) async throws -> ArchiveListResponse {
        return try await archiveService.fetchArchiveList(size: size, cursor: cursor)
    }
}
