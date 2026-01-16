//
//  MemoryCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class MemoryCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let memoryViewController = MemoryViewController()
        memoryViewController.coordinator = self
        navigationController.setViewControllers([memoryViewController], animated: false)
    }
    
    func finish() {
        
    }
}

