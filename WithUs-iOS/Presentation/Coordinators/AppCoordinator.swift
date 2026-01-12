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
        // TODO: 실제 자동 로그인 로직 구현
        // 예: UserDefaults에서 토큰 확인, Keychain에서 인증 정보 확인 등 -> apple login
        let isLoggedIn = false
        
        if isLoggedIn {
            
        } else {
            showAuthFlow()
        }
    }
    
    private func showAuthFlow() {
        let authCoordinator = AuthCoordinator(navigationController: navigationController)
        authCoordinator.delegate = self
        childCoordinators.append(authCoordinator)
        authCoordinator.start()
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        //로그인 성공시, 홈화면으로
    }
}
