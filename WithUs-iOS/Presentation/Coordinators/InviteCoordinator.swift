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
    weak var delegate: InviteCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showInvite()
    }
    
    private func showInvite() {
        let inviteCodeVC = InviteViewController()
        inviteCodeVC.coordinator = self
        navigationController.pushViewController(inviteCodeVC, animated: true)
    }
    
    func showInviteInputCode() {
        let inviteInputVC = InviteInputCodeViewController()
        navigationController.pushViewController(inviteInputVC, animated: true)
    }
    
    func showInviteCode() {
        let inviteCodeVC = InviteCodeViewController()
        navigationController.pushViewController(inviteCodeVC, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}
