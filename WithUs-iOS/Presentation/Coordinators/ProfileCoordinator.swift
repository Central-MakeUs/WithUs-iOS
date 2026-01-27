//
//  ProfileCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class ProfileCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let fetchKeywordsUseCase: FetchKeywordUseCaseProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        let keywordRepository = KeywordRepository(networkService: networkService)
        self.fetchKeywordsUseCase = FetchKeywordUseCase(keywordRepository: keywordRepository)
    }
    
    func start() {
        let profileViewController = ProfileViewController()
        profileViewController.coordinator = self
        navigationController.setViewControllers([profileViewController], animated: false)
    }
    
    func showProfileModification() {
        let modifyVC = ModifyProfileViewController(reactor: ProfileReactor())
        modifyVC.coordinator = self
        navigationController.pushViewController(modifyVC, animated: true)
    }
    
    func showKeywordModification() {
        let keywordVC = ModifyKeywordViewController(fetchKeywordsUseCase: fetchKeywordsUseCase)
        keywordVC.coordinator = self
        navigationController.pushViewController(keywordVC, animated: true)
    }
    
    func showAccountModification() {
        let accountVC = ModifyAccountViewController()
        accountVC.coordinator = self
        navigationController.pushViewController(accountVC, animated: true)
    }
    
    func finish() {
        
    }
}
