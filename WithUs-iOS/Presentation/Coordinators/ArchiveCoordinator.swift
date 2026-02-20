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
    private let reactor: ArchiveReactor?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        // Repositories
        let fetchRecentArchiveList = FetchArchiveListRepository(networkService: networkService)
        let deleteRepository = ArchiveDeleteRepository(networkService: networkService)
        
        // UseCase
        self.fetchRecentArchiveUseCase = FetchArchiveListUseCase(archiveService: fetchRecentArchiveList)
        self.deleteArchiveUseCase = ArchiveDeleteUseCase(repository: deleteRepository)
        
        // Reactor
        self.reactor = ArchiveReactor(
            fetchArchiveListUseCase: self.fetchRecentArchiveUseCase,
            deleteArchiveUseCase: deleteArchiveUseCase
        )
    }
    
    func start() {
        let archiveViewController = ArchiveViewController()
        archiveViewController.reactor = self.reactor
        archiveViewController.coordinator = self
        navigationController.setViewControllers([archiveViewController], animated: false)
    }
    
    func showQuestionDetail(_ type: ArchiveDetailType) {
        let vc = ArchiveDetailViewController(detailType: type)
        vc.reactor = self.reactor
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        
    }
}

