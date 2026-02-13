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
    func mainCoordinatorDidRequestLogout(_ coordinator: MainCoordinator)
    func mainCoordinatorDidRequestWithdrawal(_ coordinator: MainCoordinator)
}

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    weak var delegate: MainCoordinatorDelegate?
    
    // Coordinator들을 프로퍼티로 저장 (강한 참조 유지) ✅
    private var homeCoordinator: HomeCoordinator?
    private var memoryCoordinator: ArchiveCoordinator?
    private var fourCutCoordinator: FourCutCoordinator?
    private var profileCoordinator: ProfileCoordinator?
    
    let keywordService = KeywordEventService()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showMainTabBar()
    }
    
    func handleNeedUserSetup() {
        delegate?.mainCoordinatorDidFinish(self)
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
        
        let homeNavigationController = UINavigationController()
        let homeCoord = HomeCoordinator(navigationController: homeNavigationController, keywordService: keywordService)
        homeCoord.mainCoordinator = self
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
        
        let archiveNavigationController = UINavigationController()
        let archiveCoord = ArchiveCoordinator(navigationController: archiveNavigationController)
        self.memoryCoordinator = archiveCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(archiveCoord)
        archiveCoord.start()
        
        let archiveNormalImage = UIImage(named: "ic_memory_off")?.withRenderingMode(.alwaysOriginal)
        let archiveSelectedImage = UIImage(named: "ic_memory_on")?.withRenderingMode(.alwaysOriginal)
        
        archiveNavigationController.tabBarItem = UITabBarItem(
            title: "보관",
            image: archiveNormalImage,
            selectedImage: archiveSelectedImage
        )
        
        let fourCutNavigationController = UINavigationController()
        let fourCutCoord = FourCutCoordinator(navigationController: fourCutNavigationController)
        self.fourCutCoordinator = fourCutCoord // 프로퍼티에 저장 ✅
        childCoordinators.append(fourCutCoord)
        fourCutCoord.start()
        
        let fourCutNormalImage = UIImage(named: "ic_four_cut_off")?.withRenderingMode(.alwaysOriginal)
        let fourCutSelectedImage = UIImage(named: "ic_four_cut_on")?.withRenderingMode(.alwaysOriginal)
        
        fourCutNavigationController.tabBarItem = UITabBarItem(
            title: "추억",
            image: fourCutNormalImage,
            selectedImage: fourCutSelectedImage
        )
        
        let profileNavigationController = UINavigationController()
        let profileCoord = ProfileCoordinator(navigationController: profileNavigationController, keywordService: keywordService)
        self.profileCoordinator = profileCoord // 프로퍼티에 저장 ✅
        profileCoord.mainCoordinator = self
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
            fourCutNavigationController,
            archiveNavigationController,
            profileNavigationController
        ]
        
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func finish() {
        childCoordinators.removeAll()
        homeCoordinator = nil
        memoryCoordinator = nil
        fourCutCoordinator = nil
        profileCoordinator = nil
    }
    
    func handleLogout() {
        finish()
        delegate?.mainCoordinatorDidRequestLogout(self)
    }
    
    func handleWithdrawal() {
        finish()
        delegate?.mainCoordinatorDidRequestWithdrawal(self)
    }
}
