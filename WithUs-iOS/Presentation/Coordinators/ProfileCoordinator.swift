//
//  ProfileCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class ProfileCoordinator: Coordinator, ConnectCoupleCoordinatorDelegate {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    private let fetchKeywordsUseCase: FetchKeywordUseCaseProtocol
    private let fetchCoupleKeyUseCase: FetchCoupleKeywordsUseCaseProtocol
    private let keywordService: KeywordEventServiceProtocol
    
    init(navigationController: UINavigationController, keywordService: KeywordEventServiceProtocol) {
        self.navigationController = navigationController
        
        let networkService = NetworkService.shared
        let keywordRepository = KeywordRepository(networkService: networkService)
        let coupleKeywordRepository = CoupleKeywordRepository(networkService: networkService)
        self.fetchKeywordsUseCase = FetchKeywordUseCase(keywordRepository: keywordRepository)
        self.fetchCoupleKeyUseCase = FetchCoupleKeywordsUseCase(coupleKeywordRepository: coupleKeywordRepository)
        self.keywordService = keywordService
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
    
    func showAccountModification() {
        let accountVC = ModifyAccountViewController()
        accountVC.coordinator = self
        navigationController.pushViewController(accountVC, animated: true)
    }
    
    func showWithdrawal() {
        let withdrawalVC = WithdrawalViewController()
        withdrawalVC.coordinator = self
        navigationController.pushViewController(withdrawalVC, animated: true)
    }
    
    func showConnectSettings() {
        let reasonVC = WithdrawalReasonViewController()
        reasonVC.coordinator = self
        navigationController.pushViewController(reasonVC, animated: true)
    }
    
    func showCancleConnect() {
        let cancleVC = CancleConnectViewController()
        cancleVC.coordinator = self
        navigationController.pushViewController(cancleVC, animated: true)
    }
    
    // 회원 탈퇴 플로우에서의 연결 해제
    func showCancleConnectForWithdrawal(completion: @escaping () -> Void) {
        let cancleVC = CancleConnectViewController()
        cancleVC.coordinator = self
        cancleVC.onDisconnectComplete = completion
        navigationController.pushViewController(cancleVC, animated: true)
    }
    
    // CancleNotificationViewController 표시
    func showCancleNotification(onDisconnectComplete: (() -> Void)? = nil) {
        let notificationVC = CancleNotificationViewController()
        notificationVC.coordinator = self
        notificationVC.onDisconnectComplete = onDisconnectComplete
        navigationController.pushViewController(notificationVC, animated: true)
    }
    
    func handleDisconnectComplete(onComplete: @escaping () -> Void) {
        if let withdrawalVC = navigationController.viewControllers.first(where: { $0 is WithdrawalViewController }) {
            navigationController.popToViewController(withdrawalVC, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onComplete()
            }
        }
    }
    
    func showConnectCoupleFlow() {
        let connectCoordinator = ConnectCoupleCoordinator(navigationController: navigationController)
        connectCoordinator.delegate = self
        childCoordinators.append(connectCoordinator)
        connectCoordinator.start()
    }
    
    func connectCoupleCoordinatorDidFinish(_ coordinator: ConnectCoupleCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        
        if let profileVC = navigationController.viewControllers.first(where: { $0 is ProfileViewController }) {
            navigationController.popToViewController(profileVC, animated: true)
        }
    }
    
    
    func showKeywordModification() {
        let keywordVC = ModifyKeywordViewController(fetchKeywordsUseCase: fetchKeywordsUseCase)
        keywordVC.coordinator = self
        let reactor = KeywordSettingReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeyUseCase,
            keywordService: keywordService
        )
        keywordVC.reactor = reactor
        navigationController.pushViewController(keywordVC, animated: true)
    }
    
    func showCoupleSetup() {
        let reactor = KeywordSettingReactor(
            fetchCoupleKeywordsUseCase: fetchCoupleKeyUseCase,
            keywordService: keywordService
        )
        let vc = KeywordSettingViewController(fetchKeywordsUseCase: fetchKeywordsUseCase)
        vc.reactor = reactor
        navigationController.pushViewController(vc, animated: true)
    }
    
    func finish() {
        
    }
}
