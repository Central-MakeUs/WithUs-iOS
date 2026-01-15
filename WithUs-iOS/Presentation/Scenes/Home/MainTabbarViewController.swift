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
    
    private let cameraButton = UIButton().then {
        $0.setTitle("Camgiera", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator?.showInviteModal()
    }
    
    override func setupUI() {
        view.addSubview(cameraButton)
    }
    
    override func setupConstraints() {
        cameraButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.center.equalToSuperview()
        }
    }
    
    override func setupActions() {
        cameraButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
    }
    
    @objc private func showCamera() {
//        coordinator?.showCameraModal()
        let cutomCameraVC = CustomCameraViewController()
        cutomCameraVC.modalPresentationStyle = .fullScreen
        navigationController?.present(cutomCameraVC, animated: true)
    }
}
