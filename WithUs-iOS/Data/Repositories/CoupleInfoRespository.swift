//
//  CoupleInfoRespository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation

protocol CoupleInfoRespositoryProtocol {
    func getCoupleInfo() async throws -> ProfileData
}

final class CoupleInfoRespository: CoupleInfoRespositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func getCoupleInfo() async throws -> ProfileData {
        let endpoint = PartnerInfoEndpoint.getPartnerInfo
        let response = try await networkService.request(endpoint: endpoint, responseType: ProfileData.self)
        
        return response
    }
}
