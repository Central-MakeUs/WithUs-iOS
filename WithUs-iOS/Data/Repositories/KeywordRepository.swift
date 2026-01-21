//
//  KeywordRepository.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

protocol KeywordRepositoryProtocol {
    func fetchKeywords() async throws -> [Keyword]
}

final class KeywordRepository: KeywordRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchKeywords() async throws -> [Keyword] {
        let endpoint = KeywordEndpoint.fetchKeyword
        
        return try await networkService.request(endpoint: endpoint, responseType: KeywordResponse.self).keywordInfoList.sorted { $0.displayOrder < $1.displayOrder }.map { $0.toDomain() }
    }
}
