//
//  PokePartnerUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/3/26.
//

import Foundation

protocol PokePartnerUseCaseProtocol {
    func execute(id: Int) async throws
}

final class PokePartnerUseCase: PokePartnerUseCaseProtocol {
    private let pokeRepository: PokePartnerRepositoryProtocol
    
    init(pokeRepository: PokePartnerRepositoryProtocol) {
        self.pokeRepository = pokeRepository
    }
    
    func execute(id: Int) async throws {
        try await pokeRepository.pokePartner(id: id)
    }
}
