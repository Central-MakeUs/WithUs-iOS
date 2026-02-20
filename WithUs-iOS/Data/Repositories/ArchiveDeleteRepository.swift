//
//  ArchiveDeleteRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/20/26.
//

import Foundation

protocol ArchiveDeleteRepositoryProtocol {
    func archiveDelete(archiveType: String, id: Int, date: String) async throws
    func archiveBulkDelete(items: [ArchiveDeleteItem]) async throws
}

final class ArchiveDeleteRepository: ArchiveDeleteRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func archiveDelete(archiveType: String, id: Int, date: String) async throws {
        let endpoint = ArchiveDeleteEndpoint.archiveDelete(archiveType: archiveType, id: id, date: date)
        
        try await networkService.requestWithoutData(endpoint: endpoint)
    }

    func archiveBulkDelete(items: [ArchiveDeleteItem]) async throws {
        let endpoint = ArchiveDeleteEndpoint.archiveBulkDelete(items: items)
        
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
}
