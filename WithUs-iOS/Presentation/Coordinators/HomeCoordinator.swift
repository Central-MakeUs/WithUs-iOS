//
//  HomeCoordinator.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit

class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        print("✅ [HomeCood] 생성됨, navController: \(navigationController)")
    }
    
    func start() {
        print("✅ [HomeCoord] start() 호출")
        let homeViewController = HomeViewController()
        print("✅ [HomeCoord] HomeViewController 생성 완료")
        
        homeViewController.coordinator = self
        print("✅ [HomeCoord] coordinator 연결 완료, 확인: \(homeViewController.coordinator != nil)")
        
        navigationController.setViewControllers([homeViewController], animated: false)
        print("✅ [HomeCoord] setViewControllers 완료")
    }
    
    func showKeywordSetting() {
        print("\n🔥🔥🔥 [HomeCoord] showKeywordSetting() 호출됨! 🔥🔥🔥")
        print("🔥 navigationController: \(navigationController)")
        print("🔥 현재 스택: \(navigationController.viewControllers.count)개")
        
        let keywordSettingVC = KeywordSettingViewController()
        keywordSettingVC.coordinator = self
        keywordSettingVC.hidesBottomBarWhenPushed = true
        
        print("🔥 KeywordSettingViewController 생성 완료")
        print("🔥 push 시작...")
        
        navigationController.pushViewController(keywordSettingVC, animated: true)
        
        print("🔥 push 완료!")
        print("🔥 push 후 스택: \(navigationController.viewControllers.count)개")
    }
    
    func showTimeSetting() {
        let timePickerVC = TimePickerViewController()
        timePickerVC.coordinator = self
        timePickerVC.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(timePickerVC, animated: true)
        print("🔥 push 완료!")
        print("🔥 push 후 스택: \(navigationController.viewControllers.count)개")
    }
    
    func finishSetting(selectedTime: String) {
        print("✅ 설정 완료 - 시간: \(selectedTime)")
        navigationController.popToRootViewController(animated: true)
        
        if let homeVC = navigationController.viewControllers.first as? HomeViewController {
            homeVC.updateSettingStatus(isCompleted: true)
        }
    }
    
    func finish() {
        
    }
}
