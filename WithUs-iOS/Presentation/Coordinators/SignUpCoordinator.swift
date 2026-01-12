//
//  SignUpCoordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/12/26.
//

import UIKit

protocol SignUpCoordinatorDelegate: AnyObject {
    func signUpCoordinatorDidFinish(_ coordinator: SignUpCoordinator)
}

class SignUpCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: SignUpCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showSignUpNickName()
    }
    
    private func showSignUpNickName() {
        let signUpNickNameVC = SignUpNickNameViewController()
        signUpNickNameVC.coordinator = self
        navigationController.pushViewController(signUpNickNameVC, animated: true)
    }
    
    func showSignUpProfile() {
        let signUpProfileVC = SignUpProfileViewController()
        signUpProfileVC.coordinator = self
        navigationController.pushViewController(signUpProfileVC, animated: true)
    }
    
    func showInvite() {
        let inviteCoordinator = InviteCoordinator(navigationController: navigationController)
        inviteCoordinator.delegate = self
        childCoordinators.append(inviteCoordinator)
        inviteCoordinator.start()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension SignUpCoordinator: InviteCoordinatorDelegate {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator) {
        coordinator.finish()
        delegate?.signUpCoordinatorDidFinish(self)
    }
}
