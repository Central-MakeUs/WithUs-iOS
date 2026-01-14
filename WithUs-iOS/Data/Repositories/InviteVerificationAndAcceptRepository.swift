//
//  InviteVerificationAndAcceptRepository.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation
import Alamofire

protocol InviteVerificationAndAcceptRepositoryProtocol {
    func verifyCode(inviteCode: String) async throws -> VerifyCodePreviewResponse
    func acceptInvite(inviteCode: String) async throws -> CoupleCodeResponse
}

final class InviteVerificationAndAcceptRepository: InviteVerificationAndAcceptRepositoryProtocol {
    private let networkService: NetworkService
    
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    func verifyCode(inviteCode: String) async throws -> VerifyCodePreviewResponse {
        let endpoint = InviteVerificationAndAcceptEndPoint.verifyCode(inviteCode: inviteCode)
        
        return try await networkService.request(endpoint: endpoint, responseType: VerifyCodePreviewResponse.self)
    }

    func acceptInvite(inviteCode: String) async throws -> CoupleCodeResponse {
        let endpoint = InviteVerificationAndAcceptEndPoint.acceptInvite(inviteCode: inviteCode)
        return try await networkService.request(endpoint: endpoint, responseType: CoupleCodeResponse.self)
    }
}
