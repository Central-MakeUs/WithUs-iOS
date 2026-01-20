//
//  HomeRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Foundation

protocol HomeRepositoryProtocol {
    func fetchUserStatus() async throws -> UserStatusResponse
}

final class HomeRepository: HomeRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func fetchUserStatus() async throws -> UserStatusResponse {
        let endpoint = UserOnboardingStatusEndpoint.fetchStatus
        
        let response = try await networkService.request(endpoint: endpoint, responseType: UserStatusResponse.self)
        
        return response
    }
}
