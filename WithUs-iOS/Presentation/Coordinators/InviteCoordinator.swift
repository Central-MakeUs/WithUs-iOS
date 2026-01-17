//
//  InviteCoordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import UIKit

protocol InviteCoordinatorDelegate: AnyObject {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator)
}

class InviteCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    var type: CodeType
    var inputReactor: InviteInputCodeReactor?
    
    weak var delegate: InviteCoordinatorDelegate?
    
    init(navigationController: UINavigationController, type: CodeType) {
        self.navigationController = navigationController
        self.type = type
    }
    
    func start() {
        let networdService = NetworkService.shared
        
        // 코드초대
        let repository = InvitationCodeRepository(networkService: networdService)
        let useCase = GetInvitationUseCase(repository: repository)
        let reactor = InviteCodeReactor(getInvitationUseCase: useCase)
        
        // 코드입력
        let inputRepository = InviteVerificationAndAcceptRepository(networkService: networdService)
        let inputUseCase = VerifyCodePreviewUseCase(repository: inputRepository)
        inputReactor = InviteInputCodeReactor(usecase: inputUseCase)
        
        switch type {
        case .input:
            showInviteInputCode(inputReactor!)
        default:
            showInviteCode(reactor)
        }
    }
    
    func showInviteInputCode(_ reactor: InviteInputCodeReactor) {
        let inviteInputVC = InviteInputCodeViewController(reactor: reactor)
        inviteInputVC.hidesBottomBarWhenPushed = true
        inviteInputVC.coordinator = self
        navigationController.pushViewController(inviteInputVC, animated: false)
    }
    
    func showInviteCode(_ reactor: InviteCodeReactor) {
        let inviteCodeVC = InviteCodeViewController(reactor: reactor)
        inviteCodeVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(inviteCodeVC, animated: false)
    }
    
    func showInviteVerified() {
        guard let inputReactor else { return }
        let vc = InviteVerifiedViewController(reactor: inputReactor)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func showConnected() {
        guard let inputReactor else { return }
        let vc = InviteConnectedViewController(reactor: inputReactor)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func didComplete() {
        delegate?.inviteCoordinatorDidFinish(self)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}
