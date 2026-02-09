//
//  UserDeleteRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/9/26.
//

import Foundation

protocol UserDeleteRepositoryProtocol {
    func delete() async throws
}

final class UserDeleteRepository: UserDeleteRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func delete() async throws {
        let endpoint = UserDeleteEndpoint.deleteUser
        
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
}
