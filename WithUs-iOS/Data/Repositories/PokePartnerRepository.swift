//
//  PokePartnerRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/3/26.
//

import Foundation

protocol PokePartnerRepositoryProtocol {
    func pokePartner(id: Int) async throws
}

final class PokePartnerRepository: PokePartnerRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }

    func pokePartner(id: Int) async throws {
        let endpoint = PokeEndpoint.pokePartner(id)
        
        try await networkService.requestWithoutData(endpoint: endpoint)
    }
}
