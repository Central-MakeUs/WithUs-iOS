//
//  SignUpCoordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/12/26.
//

import UIKit

protocol SignUpCoordinatorDelegate: AnyObject {
    func signUpCoordinatorDidFinish(_ coordinator: SignUpCoordinator)
}

class SignUpCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: SignUpCoordinatorDelegate?
    var reactor: SignUpReactor?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let networkService = NetworkService.shared
        let imageRepository = ImageRepository(networkService: networkService)
        let userRepository = UserRepository(networkService: networkService)
        let uploadImageUseCase = UploadImageUseCase(imageRepository: imageRepository)
        let completeProfileUseCase = CompleteProfileUseCase(
            uploadImageUseCase: uploadImageUseCase,
            userRepository: userRepository
        )
        let reactor = SignUpReactor(completeProfileUseCase: completeProfileUseCase)
        self.reactor = reactor
        showSignUpNickName()
    }
    
    private func showSignUpNickName() {
        guard let reactor else { return }
        let signUpNickNameVC = SignUpNickNameViewController(reactor: reactor)
        signUpNickNameVC.coordinator = self
        navigationController.pushViewController(signUpNickNameVC, animated: false)
    }
    
    func showSignUpProfile() {
        guard let reactor else { return }
        let signUpProfileVC = SignUpProfileViewController(reactor: reactor)
        signUpProfileVC.coordinator = self
        navigationController.pushViewController(signUpProfileVC, animated: false)
    }
    
    // 회원가입 완료
    func didCompleteSignUp() {
        UserDefaults.standard.set(false, forKey: "isSettingCompleted")
        delegate?.signUpCoordinatorDidFinish(self)
    }
    
    func finish() {
        childCoordinators.removeAll()
    }
}
