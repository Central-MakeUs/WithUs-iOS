//
//  NotiCenterUsecase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/26/26.
//

import Foundation

protocol NotiCenterUsecaseProtocol {
    func execute(size: Int, cursor: String?) async throws -> NotiCenterListResponse
}

final class NotiCenterUsecase: NotiCenterUsecaseProtocol {
    private let repository: NotiCenterRepositoryProtocol
    
    init(repository: NotiCenterRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(size: Int, cursor: String?) async throws -> NotiCenterListResponse {
        return try await repository.fetchNotiCenter(size: size, cursor: cursor)
    }
}
