//
//  FetchUserStatusUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Foundation

protocol FetchUserStatusUseCaseProtocol {
    func execute() async throws -> OnboardingStatus
}

final class FetchUserStatusUseCase: FetchUserStatusUseCaseProtocol {
    private let repository: HomeRepositoryProtocol
    
    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> OnboardingStatus {
        return try await repository.fetchUserStatus().onboardingStatus
    }
}

