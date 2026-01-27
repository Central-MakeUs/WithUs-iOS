//
//  ArchiveCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class ArchiveCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let archiveViewController = ArchiveViewController()
        archiveViewController.coordinator = self
        navigationController.setViewControllers([archiveViewController], animated: false)
    }
    
    func finish() {
        
    }
}

