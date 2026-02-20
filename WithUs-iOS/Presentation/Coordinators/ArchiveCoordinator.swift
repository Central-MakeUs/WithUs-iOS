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
    private let deleteArchiveUseCase: ArchiveDeleteUseCaseProtocol
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        // Repositories
        let fetchRecentArchiveList = FetchArchiveListRepository(networkService: networkService)
        let deleteRepository = ArchiveDeleteRepository(networkService: networkService)
        
        // UseCase
        self.fetchRecentArchiveUseCase = FetchArchiveListUseCase(archiveService: fetchRecentArchiveList)
        self.deleteArchiveUseCase = ArchiveDeleteUseCase(repository: deleteRepository)
    }
    
    func start() {
        let reactor = ArchiveReactor(
            fetchArchiveListUseCase: self.fetchRecentArchiveUseCase,
            deleteArchiveUseCase: deleteArchiveUseCase
        )
        let archiveViewController = ArchiveViewController()
        archiveViewController.reactor = reactor
        archiveViewController.coordinator = self
        navigationController.setViewControllers([archiveViewController], animated: false)
    }
    
    func showQuestionDetail(_ type: ArchiveDetailType) {
        let vc = ArchiveDetailViewController(detailType: type)
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        
    }
}

