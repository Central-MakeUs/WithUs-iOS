//
//  MainCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import UIKit

enum CodeType {
    case input
    case invite
}

protocol MainCoordinatorDelegate: AnyObject {
    func mainCoordinatorDidFinish(_ coordinator: MainCoordinator)
}

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: MainCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainTab()
    }
    
    private func showMainTab() {
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    func showInviteModal() {
        let inviteModalVC = InviteViewController()
        inviteModalVC.coordinator = self
        inviteModalVC.modalPresentationStyle = .fullScreen
        navigationController.present(inviteModalVC, animated: true)
    }
    
    func startInviteFlow(_ type: CodeType) {
        let inviteCoordinator = InviteCoordinator(navigationController: navigationController, type: type)
        inviteCoordinator.delegate = self
        childCoordinators.append(inviteCoordinator)
        inviteCoordinator.start()
    }
    
    func showCameraModal() {
        let cutomCameraVC = CustomCameraViewController()
        cutomCameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cutomCameraVC, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension MainCoordinator: InviteCoordinatorDelegate {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
    }
}
