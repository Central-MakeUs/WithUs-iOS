//
//  ArchiveDeleteUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/20/26.
//

import Foundation

protocol ArchiveDeleteUseCaseProtocol {
    func execute(archiveType: String, id: Int, date: String) async throws
    func execute(items: [ArchiveDeleteItem]) async throws
}

final class ArchiveDeleteUseCase: ArchiveDeleteUseCaseProtocol {
    private let repository: ArchiveDeleteRepositoryProtocol
    
    init(repository: ArchiveDeleteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(archiveType: String, id: Int, date: String) async throws {
        try await repository.archiveDelete(archiveType: archiveType, id: id, date: date)
    }
    
    func execute(items: [ArchiveDeleteItem]) async throws {
        try await repository.archiveBulkDelete(items: items)
    }
}
