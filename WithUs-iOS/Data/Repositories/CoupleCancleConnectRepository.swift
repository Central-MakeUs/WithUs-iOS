//
//  CoupleCancleConnectRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/4/26.
//

import Foundation

protocol CoupleCancleConnectRepositoryProtocol {
    func cancleCouple() async throws
}

final class CoupleCancleConnectRepository: CoupleCancleConnectRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func cancleCouple() async throws {
        let endpoint = CoupleCancleConnectEndpoint.cancelConnect
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
}
