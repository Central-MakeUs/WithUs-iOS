//
//  FetchUserInfoUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation

protocol FetchUserInfoUseCaseProtocol {
    func execute() async throws -> User
}

final class FetchUserInfoUseCase: FetchUserInfoUseCaseProtocol {
    
    private let userRepository: UpdateUserRepositoryProtocol
    
    init(userRepository: UpdateUserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute() async throws -> User {
        let response = try await userRepository.getProfile()
        return User(from: response)
    }
}
