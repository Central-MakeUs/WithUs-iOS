//
//  InvitationCodeRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import Alamofire

protocol InvitationCodeRepositoryProtocol {
    func getInvitationCode() async throws -> InvitationCodeResponse
}

final class InvitationCodeRepository: InvitationCodeRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func getInvitationCode() async throws -> InvitationCodeResponse {
        let endpoint = InvitationCodeEndPoint.getInviteCode
        
        return try await networkService.request(endpoint: endpoint, responseType: InvitationCodeResponse.self)
    }
}
