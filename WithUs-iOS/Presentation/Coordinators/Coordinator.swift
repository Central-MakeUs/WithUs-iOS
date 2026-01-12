//
//  Coordinator.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/12/26.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
    func finish()
}
