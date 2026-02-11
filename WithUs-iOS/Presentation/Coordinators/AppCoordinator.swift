//
//  AppCoordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/12/26.
//

import UIKit

class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.navigationController.setNavigationBarHidden(true, animated: false)
    }
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        checkAutoLogin()
    }
    
    private func checkAutoLogin() {
        if let token = TokenManager.shared.accessToken, !token.isEmpty {
            print("✅ 자동 로그인: 토큰 있음")
            showMainFlow()
        } else {
            print("❌ 자동 로그인: 토큰 없음")
            if UserDefaultsManager.shared.shouldShowLogin {
                showLoginFlow()
            } else {
                showAuthFlow()
            }
        }
    }
    
    private func showAuthFlow() {
        childCoordinators.removeAll()
        
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    private func showLoginFlow() {
        childCoordinators.removeAll()
        
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.showLogin()
    }
    
    func showSignUpFlowOnly() {
        childCoordinators.removeAll()
        
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.startWithSignUp()
    }
    
    private func showMainFlow() {
        childCoordinators.removeAll()
        
        let mainCoordinator = MainCoordinator(navigationController: navigationController)
        mainCoordinator.delegate = self
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

//MARK: 부모배열에서 나를 제거하고 내 자식들도 다 제거한다
extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator) {
        
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
        
        showMainFlow()
    }
}

extension AppCoordinator: MainCoordinatorDelegate {
    func mainCoordinatorDidFinish(_ coordinator: MainCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
        
        showSignUpFlowOnly()
    }
    
    func mainCoordinatorDidRequestLogout(_ coordinator: MainCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()

        showLoginFlow()
    }
    
    func mainCoordinatorDidRequestWithdrawal(_ coordinator: MainCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
        
        showAuthFlow()
    }
}
