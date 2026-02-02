//
//  FetchArchiveListRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/2/26.
//

import Foundation

protocol FetchArchiveListRepositoryProtocol {
    func fetchArchiveList(size: Int, cursor: String?) async throws -> ArchiveListResponse
}


final class FetchArchiveListRepository: FetchArchiveListRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchArchiveList(size: Int, cursor: String?) async throws -> ArchiveListResponse {
        let endpoint = FetchArchiveListEndPoint.fetchArchiveList(size: size, cursor: cursor)

        let response = try await networkService.request(endpoint: endpoint, responseType: ArchiveListResponse.self)
        
        
        return response
    }
}




















