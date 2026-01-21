//
//  AuthCoordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/12/26.
//

import UIKit

protocol AuthCoordinatorDelegate: AnyObject {
    func authCoordinatorDidFinish(_ coordinator: AuthCoordinator)
}

class AuthCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: AuthCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showOnboarding()
    }
    
    func startWithSignUp() {
        showSignup()
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        navigationController.setViewControllers([onboardingVC], animated: false)
    }
    
    func showLogin() {
        let networdService = NetworkService.shared
        let repository = LoginRepository(networkService: networdService)
        let useCase = KakaoLoginUseCase(repository: repository)
        let reactor = LoginReactor(kakaoLoginUseCase: useCase)
        let loginVC = LoginViewController(reactor: reactor)
        loginVC.coordinator = self
        navigationController.pushViewController(loginVC, animated: true)
    }
    
    func showSignup() {
        let signUpCoordinator = SignUpCoordinator(navigationController: navigationController)
        signUpCoordinator.delegate = self
        childCoordinators.append(signUpCoordinator)
        signUpCoordinator.start()
    }
    
    func didLogin() {
        delegate?.authCoordinatorDidFinish(self)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}

extension AuthCoordinator: SignUpCoordinatorDelegate {
    func signUpCoordinatorDidFinish(_ coordinator: SignUpCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
        
        delegate?.authCoordinatorDidFinish(self)
    }
}
