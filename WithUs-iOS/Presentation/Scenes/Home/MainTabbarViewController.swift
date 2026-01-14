//
//  MainTabbarViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import UIKit
import SnapKit
import Then

//MARK: Test
final class HomeViewController: BaseViewController {
    
    weak var coordinator: MainCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.showInviteModal()
    }
}
