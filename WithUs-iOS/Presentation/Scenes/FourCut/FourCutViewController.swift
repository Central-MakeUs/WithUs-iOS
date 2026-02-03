//
//  FourCutViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then

class FourCutViewController: BaseViewController {
    weak var coordinator: FourCutCoordinator?
    
    private let addButton = UIButton().then {
        $0.setImage(UIImage(named: "ic_add_four_cut"), for: .normal)
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(addButton)
    }
    
    override func setupConstraints() {
        addButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-25)
            $0.right.equalToSuperview().offset(-18)
            $0.size.equalTo(CGSize(width: 54, height: 54))
        }
    }
    
    override func setupActions() {
        addButton.addTarget(self, action: #selector(didAddButtonTapped), for: .touchUpInside)
    }
    
    override func setNavigation() {
        self.navigationItem.leftBarButtonItem?.title = "네컷"
        setRightBarButton(image: UIImage(named: "ic_four_cut_setting"))
    }
    
    @objc private func didAddButtonTapped() {
        coordinator?.showFrameSelection()
    }
}
