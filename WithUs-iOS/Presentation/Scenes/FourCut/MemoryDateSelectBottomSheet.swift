//
//  MemoryDateSelectBottomSheet.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/5/26.
//

import Foundation
import UIKit
import SnapKit
import Then

protocol MemoryDateSelectDelegate: AnyObject {
    
}

final class MemoryDateSelectBottomSheetViewController: BaseViewController {
    
    private var viewTranslation = CGPoint(x: 0, y: 0)
    
    private let localBlackView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let barView = UIView().then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 3
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        localBlackView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.3) {
            self.localBlackView.alpha = 1
            self.containerView.transform = .identity
        }
    }
    
    override func setupUI() {
        view.addSubview(localBlackView)
        
        localBlackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.addSubview(barView)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        barView.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 56, height: 6))
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(confirmBtnTapped))
        localBlackView.addGestureRecognizer(tapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        containerView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        switch sender.state {
        case .changed:
            viewTranslation = translation
            if translation.y > 0 {
                containerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
            }
        case .ended:
            if viewTranslation.y > 150 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                    self.localBlackView.alpha = 0
                }) { _ in
                    self.dismiss(animated: false)
                }
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.containerView.transform = .identity
                    self.localBlackView.alpha = 1
                }
            }
        default:
            break
        }
    }
    
    @objc private func confirmBtnTapped() {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
            self.localBlackView.alpha = 0
        }) { _ in
            self.dismiss(animated: false)
        }
    }
    
}
