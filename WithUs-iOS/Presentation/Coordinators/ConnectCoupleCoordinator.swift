//
//  ConnectCoupleCoordinator.swift
//  WithUs-iOS
//
//  Created on 1/27/26.
//

import UIKit

protocol InviteCoordinatorProtocol: AnyObject {
    func showInviteVerified()
    func showConnected()
    func didComplete()
}

protocol ConnectCoupleCoordinatorDelegate: AnyObject {
    func connectCoupleCoordinatorDidFinish(_ coordinator: ConnectCoupleCoordinator)
}

class ConnectCoupleCoordinator: Coordinator, InviteCoordinatorProtocol {
    var childCoordinators: [Coordinator] = []
    var  navigationController: UINavigationController
    var inputReactor: InviteInputCodeReactor?
    
    weak var delegate: ConnectCoupleCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showConnectCoupleInvite()
    }
    
    private func showConnectCoupleInvite() {
        let connectVC = ConnectCoupleInviteViewController()
        connectVC.coordinator = self
        navigationController.pushViewController(connectVC, animated: true)
    }
    
    func showInviteInputCode() {
        let networkService = NetworkService.shared
        let inputRepository = InviteVerificationAndAcceptRepository(networkService: networkService)
        let inputUseCase = VerifyCodePreviewUseCase(repository: inputRepository)
        inputReactor = InviteInputCodeReactor(usecase: inputUseCase)
        
        let inviteInputVC = InviteInputCodeViewController(reactor: inputReactor!)
        inviteInputVC.hidesBottomBarWhenPushed = true
        inviteInputVC.coordinator = self
        navigationController.pushViewController(inviteInputVC, animated: true)
    }
    
    func showInviteCode() {
        let networkService = NetworkService.shared
        let repository = InvitationCodeRepository(networkService: networkService)
        let useCase = GetInvitationUseCase(repository: repository)
        let reactor = InviteCodeReactor(getInvitationUseCase: useCase)
        
        let inviteCodeVC = InviteCodeViewController(reactor: reactor)
        inviteCodeVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(inviteCodeVC, animated: true)
    }
    
    func showInviteVerified() {
        guard let inputReactor else { return }
        let vc = InviteVerifiedViewController(reactor: inputReactor)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showConnected() {
        guard let inputReactor else { return }
        let vc = InviteConnectedViewController(reactor: inputReactor)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func didComplete() {
        delegate?.connectCoupleCoordinatorDidFinish(self)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}
