//
//  UserDeleteUsecase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation

protocol UserDeleteUsecaseProtocol {
    func execute() async throws
}

final class UserDeleteUsecase: UserDeleteUsecaseProtocol {
    private let repository: UserDeleteRepositoryProtocol
    
    init(repository: UserDeleteRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws {
        try await repository.delete()
    }
}
