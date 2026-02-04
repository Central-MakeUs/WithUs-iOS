//
//  FetchKeywordUseCase.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/22/26.
//

import Foundation

protocol FetchKeywordUseCaseProtocol {
    func execute() async throws -> [Keyword]
}

final class FetchKeywordUseCase: FetchKeywordUseCaseProtocol {
    private let keywordRepository: KeywordRepositoryProtocol
    
    init(keywordRepository: KeywordRepositoryProtocol) {
        self.keywordRepository = keywordRepository
    }
    
    func execute() async throws -> [Keyword] {
        return try await keywordRepository.fetchKeywords()
    }
}

protocol FetchSelectedKeywordUseCaseProtocol {
    func execute() async throws -> [KeywordCellData]
}

final class FetchSelectedKeywordUseCase: FetchSelectedKeywordUseCaseProtocol {
    private let keywordRepository: KeywordRepositoryProtocol
    
    init(keywordRepository: KeywordRepositoryProtocol) {
        self.keywordRepository = keywordRepository
    }
    
    func execute() async throws -> [KeywordCellData] {
        let selectedInfos = try await keywordRepository.fetchSelectedKeywords()
        
        return selectedInfos.map { info in
            KeywordCellData(
                keyword: info.toDomain(),
                isSelected: info.isSelected
            )
        }
    }
}
