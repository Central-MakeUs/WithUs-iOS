//
//  MainCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import UIKit

enum CodeType {
    case input
    case invite
}

protocol MainCoordinatorDelegate: AnyObject {
    func mainCoordinatorDidFinish(_ coordinator: MainCoordinator)
}

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: MainCoordinatorDelegate?
    
    // Coordinator들을 프로퍼티로 저장 (강한 참조 유지) ✅
    private var homeCoordinator: HomeCoordinator?
    private var memoryCoordinator: MemoryCoordinator?
    private var fourCutCoordinator: FourCutCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainTabBar()
    }
    
    private func showMainTabBar() {
        let tabBarController = UITabBarController()
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = UIColor.systemGray5
        
        appearance.stackedLayoutAppearance.normal.iconColor = .gray500
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray500,
            .font: UIFont.pretendard10Regular
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .gray900
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.gray900,
            .font: UIFont.pretendard(.bold, size: 10)
        ]
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        // 홈 탭
        let homeNavigationController = UINavigationController()
        let homeCoord = HomeCoordinator(navigationController: homeNavigationController)
        self.homeCoordinator = homeCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(homeCoord)
        homeCoord.start()
        
        let homeNormalImage = UIImage(named: "ic_home_off")?.withRenderingMode(.alwaysOriginal)
        let homeSelectedImage = UIImage(named: "ic_home_on")?.withRenderingMode(.alwaysOriginal)
        
        homeNavigationController.tabBarItem = UITabBarItem(
            title: "홈",
            image: homeNormalImage,
            selectedImage: homeSelectedImage
        )
        
        // 추억 탭
        let memoryNavigationController = UINavigationController()
        let memoryCoord = MemoryCoordinator(navigationController: memoryNavigationController)
        self.memoryCoordinator = memoryCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(memoryCoord)
        memoryCoord.start()
        
        let memoryNormalImage = UIImage(named: "ic_memory_off")?.withRenderingMode(.alwaysOriginal)
        let memorySelectedImage = UIImage(named: "ic_memory_on")?.withRenderingMode(.alwaysOriginal)
        
        memoryNavigationController.tabBarItem = UITabBarItem(
            title: "추억",
            image: memoryNormalImage,
            selectedImage: memorySelectedImage
        )
        
        // 네컷 탭
        let fourCutNavigationController = UINavigationController()
        let fourCutCoord = FourCutCoordinator(navigationController: fourCutNavigationController)
        self.fourCutCoordinator = fourCutCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(fourCutCoord)
        fourCutCoord.start()
        
        let fourCutNormalImage = UIImage(named: "ic_four_cut_off")?.withRenderingMode(.alwaysOriginal)
        let fourCutSelectedImage = UIImage(named: "ic_four_cut_on")?.withRenderingMode(.alwaysOriginal)
        
        fourCutNavigationController.tabBarItem = UITabBarItem(
            title: "활동",
            image: fourCutNormalImage,
            selectedImage: fourCutSelectedImage
        )
        
        // 프로필 탭
        let profileNavigationController = UINavigationController()
        let profileCoord = ProfileCoordinator(navigationController: profileNavigationController)
        self.profileCoordinator = profileCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(profileCoord)
        profileCoord.start()
        
        let profileNormalImage = UIImage(named: "ic_user_off")?.withRenderingMode(.alwaysOriginal)
        let profileSelectedImage = UIImage(named: "ic_user_on")?.withRenderingMode(.alwaysOriginal)
        
        profileNavigationController.tabBarItem = UITabBarItem(
            title: "프로필",
            image: profileNormalImage,
            selectedImage: profileSelectedImage
        )
        
        tabBarController.viewControllers = [
            homeNavigationController,
            memoryNavigationController,
            fourCutNavigationController,
            profileNavigationController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
    
    func showInviteModal() {
        let inviteModalVC = InviteViewController()
        inviteModalVC.coordinator = self
        inviteModalVC.modalPresentationStyle = .fullScreen
        navigationController.present(inviteModalVC, animated: true)
    }
    
    func startInviteFlow(_ type: CodeType) {
        let inviteCoordinator = InviteCoordinator(navigationController: navigationController, type: type)
        inviteCoordinator.delegate = self
        childCoordinators.append(inviteCoordinator)
        inviteCoordinator.start()
    }
    
    func showCameraModal() {
        let cutomCameraVC = CustomCameraViewController()
        cutomCameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cutomCameraVC, animated: true)
    }
    
    func finish() {
        childCoordinators.removeAll()
        homeCoordinator = nil
        memoryCoordinator = nil
        fourCutCoordinator = nil
        profileCoordinator = nil
    }
}

extension MainCoordinator: InviteCoordinatorDelegate {
    func inviteCoordinatorDidFinish(_ coordinator: InviteCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
        coordinator.finish()
    }
}
