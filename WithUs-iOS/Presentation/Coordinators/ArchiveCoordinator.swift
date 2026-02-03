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
    private let fetchRecentArchiveUseCase: FetchArchiveListUseCase
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        // Repositories
        let fetchRecentArchiveList = FetchArchiveListRepository(networkService: networkService)
        
        // UseCase
        self.fetchRecentArchiveUseCase = FetchArchiveListUseCase(archiveService: fetchRecentArchiveList)
    }
    
    func start() {
        let reactor = ArchiveReactor(fetchArchiveListUseCase: self.fetchRecentArchiveUseCase)
        let archiveViewController = ArchiveViewController()
        archiveViewController.reactor = reactor
        archiveViewController.coordinator = self
        navigationController.setViewControllers([archiveViewController], animated: false)
    }
    
    func showQuestionDetail(_ questionDetail: ArchiveQuestionDetailResponse) {
        let vc = ArchiveDetailViewController(questionDetail: questionDetail)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        
    }
}

