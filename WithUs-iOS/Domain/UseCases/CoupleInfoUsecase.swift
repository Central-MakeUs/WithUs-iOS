//
//  CoupleInfoUsecase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation

protocol CoupleInfoUsecaseProtocol {
    func execute() async throws -> ProfileData
}

final class CoupleInfoUsecase: CoupleInfoUsecaseProtocol {
    private let repository: CoupleInfoRespositoryProtocol
    
    init(repository: CoupleInfoRespositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> ProfileData {
        let response = try await repository.getCoupleInfo()
        
        return response
    }
}
