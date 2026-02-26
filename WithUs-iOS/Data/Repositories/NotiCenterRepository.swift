//
//  NotiCenterRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/26/26.
//

import Foundation

protocol NotiCenterRepositoryProtocol {
    func fetchNotiCenter(size: Int, cursor: String?) async throws -> NotiCenterListResponse
}

final class NotiCenterRepository: NotiCenterRepositoryProtocol {
    
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
   
    func fetchNotiCenter(size: Int, cursor: String?) async throws -> NotiCenterListResponse {
        let endpoint = NotiCenterEndpoint.fetchNotiCenter(size: size, cursor: cursor)
        
        let response = try await networkService.request(endpoint: endpoint, responseType: NotiCenterListResponse.self)
        return response
    }
}
