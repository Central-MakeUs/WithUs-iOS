//
//  UpdateUserRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/31/26.
//

import Foundation

protocol UpdateUserRepositoryProtocol {
    func updateProfile(
        nickname: String,
        birthday: String,
        imageKey: String?,
        isImageUpdated: Bool
    ) async throws -> PutUpdateProfileResponse
    
    func getProfile() async throws -> PutUpdateProfileResponse
}

final class UpdateUserRepository: UpdateUserRepositoryProtocol {
    private let networdService: NetworkService
    
    init(networdService: NetworkService = .shared) {
        self.networdService = networdService
    }
    
    func updateProfile(nickname: String, birthday: String, imageKey: String?, isImageUpdated: Bool) async throws -> PutUpdateProfileResponse {
        let endpoint = PutUserEndpoint.updateProfile(
            nickname: nickname,
            birthday: birthday,
            imageKey: imageKey,
            isImageUpdated: isImageUpdated
        )
        
        let response: PutUpdateProfileResponse = try await networdService.request(endpoint: endpoint, responseType: PutUpdateProfileResponse.self)
        
        return response
    }
    
    func getProfile() async throws -> PutUpdateProfileResponse {
        let endpoint = PutUserEndpoint.getProfile
        
        let response: PutUpdateProfileResponse = try await networdService.request(endpoint: endpoint, responseType: PutUpdateProfileResponse.self)
        
        return response
    }
}
