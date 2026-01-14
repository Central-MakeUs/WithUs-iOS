//
//  VerifyCodePreviewUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct VerifyCodePreviewResult {
    let senderName: String
    let myName: String
    let inviteCode: String
    
    init(response: VerifyCodePreviewResponse) {
        self.senderName = response.senderName
        self.myName = response.receiverName
        self.inviteCode = response.inviteCode
    }
}

protocol VerifyCodePreviewUseCaseProtocol {
    func executeVerfy(inviteCode: String) async throws -> VerifyCodePreviewResult
    func executeAccept(inviteCode: String) async throws -> CoupleCode
}

final class VerifyCodePreviewUseCase: VerifyCodePreviewUseCaseProtocol {
    private let repository: InviteVerificationAndAcceptRepositoryProtocol
    
    init(repository: InviteVerificationAndAcceptRepositoryProtocol) {
        self.repository = repository
    }
    
    func executeVerfy(inviteCode: String) async throws -> VerifyCodePreviewResult {
        let response = try await repository.verifyCode(inviteCode: inviteCode)
        return VerifyCodePreviewResult(response: response)
    }
    
    func executeAccept(inviteCode: String) async throws -> CoupleCode {
        let response = try await repository.acceptInvite(inviteCode: inviteCode)
        return CoupleCode(response: response)
    }
}
