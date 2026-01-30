//
//  CoupleKeywordRepository.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

protocol CoupleKeywordRepositoryProtocol {
    func fetchCoupleKeywords() async throws -> [Keyword]
    func updateCoupleKeywords(defaultKeywordIds: [Int], customKeywords: [String]) async throws
}

final class CoupleKeywordRepository: CoupleKeywordRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchCoupleKeywords() async throws -> [Keyword] {
        let endpoint = CoupleKeywordEndpoint.getCoupleKeywords
        
        let response = try await networkService.request(
            endpoint: endpoint,
            responseType: CoupleKeywordDataResponse.self
        )
        
        return response.coupleKeywords.map { $0.toDomain() }
    }
    
    func updateCoupleKeywords(defaultKeywordIds: [Int], customKeywords: [String]) async throws {
        let endPoint = CoupleKeywordEndpoint.setCoupleKeywords(defaultKeywordIds: defaultKeywordIds, customKeywords: customKeywords)
        
        try await networkService.requestWithoutData(endpoint: endPoint)
    }
}

