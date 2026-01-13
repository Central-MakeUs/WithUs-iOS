//
//  UserProfileUseCase.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(
        nickname: String,
        imageObjectKey: String?
    ) async throws -> UpdateProfileResult
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let repository: UserRepositoryProtocol
    
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(
        nickname: String,
        imageObjectKey: String?
    ) async throws -> UpdateProfileResult {
        guard !nickname.isEmpty else {
            throw ValidationError.emptyNickname
        }
        
        let response = try await repository.updateProfile(
            nickname: nickname,
            imageObjectKey: imageObjectKey
        )
        
        return UpdateProfileResult(from: response)
    }
}

enum ValidationError: Error {
    case emptyNickname
    
    var message: String {
        switch self {
        case .emptyNickname:
            return "닉네임을 입력해주세요."
        }
    }
}
