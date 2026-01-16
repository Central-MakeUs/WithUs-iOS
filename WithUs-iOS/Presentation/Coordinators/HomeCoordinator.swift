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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let homeViewController = HomeViewController()
        homeViewController.coordinator = self
        navigationController.setViewControllers([homeViewController], animated: false)
    }
    
    func showRecordingPermission() {
        // 녹음 권한 요청 화면으로 이동하는 로직
        print("녹음 권한 요청 화면으로 이동")
    }
    
    func finish() {
        
    }
}
