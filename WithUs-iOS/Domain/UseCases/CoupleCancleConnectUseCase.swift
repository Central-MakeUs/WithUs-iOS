//
//  CoupleCancleConnectUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/4/26.
//

import Foundation

protocol CoupleCancleConnectUseCaseProtocol {
    func execute() async throws
}

final class CoupleCancleConnectUseCase: CoupleCancleConnectUseCaseProtocol {
    private let repository: CoupleCancleConnectRepositoryProtocol
    
    init(repository: CoupleCancleConnectRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.cancleCouple()
    }
}
