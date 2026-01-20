//
//  HomeCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private var inviteCoordinator: InviteCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let networkService = NetworkService.shared
        let repository = HomeRepository(networkService: networkService)
        let fetchUserStatusUseCase = FetchUserStatusUseCase(repository: repository)
        let reactor = HomeReactor(fetchUserStatusUseCase: fetchUserStatusUseCase)
        let homeViewController = HomeViewController()
        homeViewController.reactor = reactor
        homeViewController.coordinator = self
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showKeywordSetting() {
        let keywordSettingVC = KeywordSettingViewController()
        keywordSettingVC.coordinator = self
        keywordSettingVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(keywordSettingVC, animated: true)
    }
    
    func showTimeSetting() {
        let timePickerVC = TimePickerViewController()
        timePickerVC.coordinator = self
        timePickerVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(timePickerVC, animated: true)
    }
    
    func finishSetting(selectedTime: String) {
        navigationController.popToRootViewController(animated: true)
        
        if let homeVC = navigationController.viewControllers.first as? HomeViewController {
            homeVC.updateSettingStatus(isCompleted: true)
        }
    }
    
    func showCameraModal() {
        let cutomCameraVC = CustomCameraViewController()
        cutomCameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cutomCameraVC, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
        inviteCoordinator = nil
    }
    
    func showInviteModal() {
        let inviteModalVC = InviteViewController()
        inviteModalVC.coordinator = self
        inviteModalVC.modalPresentationStyle = .fullScreen
        navigationController.present(inviteModalVC, animated: true)
    }

    func startInviteFlow(_ type: CodeType) {
         let inviteCoord = InviteCoordinator(navigationController: navigationController, type: type)
         inviteCoord.delegate = self
         self.inviteCoordinator = inviteCoord
         childCoordinators.append(inviteCoord)
         inviteCoord.start()
     }
     
}

extension HomeCoordinator: InviteCoordinatorDelegate {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        inviteCoordinator = nil
        coordinator.finish()
    }
}
