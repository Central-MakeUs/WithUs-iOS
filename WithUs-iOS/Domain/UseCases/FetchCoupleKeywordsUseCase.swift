//
//  FetchCoupleKeywordsUseCase.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

protocol FetchCoupleKeywordsUseCaseProtocol {
    func execute() async throws -> [Keyword]
}

final class FetchCoupleKeywordsUseCase: FetchCoupleKeywordsUseCaseProtocol {
    private let coupleKeywordRepository: CoupleKeywordRepositoryProtocol
    
    init(coupleKeywordRepository: CoupleKeywordRepositoryProtocol) {
        self.coupleKeywordRepository = coupleKeywordRepository
    }
    
    func execute() async throws -> [Keyword] {
        return try await coupleKeywordRepository.fetchCoupleKeywords()
    }
}
