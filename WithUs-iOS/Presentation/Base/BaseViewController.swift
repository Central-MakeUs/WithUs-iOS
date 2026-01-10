//
//  BaseViewController.swift
//  WithUs-iOS
//
//  Created by 지상률 on 12/31/25.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
    
    func setupUI() {
        view.backgroundColor = .white
    }
    
    func setupConstraints() {
    }
}

