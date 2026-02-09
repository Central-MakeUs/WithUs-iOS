//
//  MemoryContentRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/6/26.
//

import Foundation

protocol MemoryContentRepositoryProtocol {
    func uploadImage(imageKey: String, title: String) async throws
    func fetchImage(year: Int, month: Int) async throws -> MemorySummaryResponse
    func makeMemory(weekEndDate: String, imageKey: String) async throws
    func fetchDetailImage(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) async throws -> MemoryDetailSummaryResponse
}

final class MemoryContentRepository: MemoryContentRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func uploadImage(imageKey: String, title: String) async throws {
        let endpoint = MemoryContentEndpoint.uploadImage(imageKey: imageKey, title: title)
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
    
    func fetchImage(year: Int, month: Int) async throws -> MemorySummaryResponse {
        let endpoint = MemoryContentEndpoint.fetchImage(year: year, month: month)
        let response = try await networkService.request(endpoint: endpoint, responseType: MemorySummaryResponse.self)
        return response
    }
    
    func makeMemory(weekEndDate: String, imageKey: String) async throws {
        let endpoint = MemoryContentEndpoint.makeMemory(weekEndDate: weekEndDate, imageKey: imageKey)
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
    
    func fetchDetailImage(memoryType: MemoryType, weekEndDate: String?, targetId: Int?) async throws -> MemoryDetailSummaryResponse {
        let endpoint = MemoryContentEndpoint.fetchDetailImage(memoryType: memoryType, weekEndDate: weekEndDate, targetId: targetId)
        
        let response = try await networkService.request(endpoint: endpoint, responseType: MemoryDetailSummaryResponse.self)
        return response
    }
}
