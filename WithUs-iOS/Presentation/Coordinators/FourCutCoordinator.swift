//
//  FourCutCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class FourCutCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let fourCutViewController = FourCutViewController()
        fourCutViewController.coordinator = self
        navigationController.setViewControllers([fourCutViewController], animated: false)
    }
    
    func finish() {
        
    }
}
