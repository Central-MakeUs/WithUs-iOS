//
//  UserRepository.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func updateProfile(
        nickname: String,
        imageObjectKey: String?
    ) async throws -> UpdateProfileResponse
}

final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func updateProfile(
        nickname: String,
        imageObjectKey: String?
    ) async throws -> UpdateProfileResponse {
        let endpoint = UserEndpoint.updateProfile(
            nickname: nickname,
            imageObjectKey: imageObjectKey
        )
        
        return try await networkService.request(
            endpoint: endpoint,
            responseType: UpdateProfileResponse.self
        )
    }
}
