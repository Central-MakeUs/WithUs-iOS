//
//  GetInvitationUseCase.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import Foundation

struct InvitationCodeResult {
    let invitationCode: String
    
    init(reponse: InvitationCodeResponse) {
        self.invitationCode = reponse.invitationCode
    }
}

protocol GetInvitationUseCaseProtocol {
    func execute() async throws -> InvitationCodeResult
}

final class GetInvitationUseCase: GetInvitationUseCaseProtocol {
    private let repository: InvitationCodeRepositoryProtocol
    
    init(repository: InvitationCodeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> InvitationCodeResult {
        let response = try await repository.getInvitationCode()
        return InvitationCodeResult(reponse: response)
    }
}

enum InvitationCodeError: Error {
    case empthCode
    case fail
    
    var message: String {
        switch self {
        case .empthCode:
            return "초대코드가 없습니다."
        case .fail:
            return "초대코드를 받아오지 못했습니다. 다시 시도해 주세요."
        }
    }
}
