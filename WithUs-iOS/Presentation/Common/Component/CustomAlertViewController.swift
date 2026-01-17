//
//  CustomAlertViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/17/26.
//

import UIKit
import SnapKit
import Then

final class CustomAlertViewController: UIViewController {
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = .black.withAlphaComponent(0.5)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard(.bold, size: 20)
        $0.textColor = .gray900
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let messageLabel = UILabel().then {
        $0.font = UIFont.pretendard(.regular, size: 16)
        $0.textColor = .gray700
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let separatorLine = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    private let confirmButton = UIButton().then {
        $0.setTitleColor(.systemRed, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.semiBold, size: 17)
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitleColor(.gray500, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard(.regular, size: 17)
    }
    
    private let buttonSeparator = UIView().then {
        $0.backgroundColor = .gray200
    }
    
    private let alertTitle: String
    private let message: String
    private let confirmTitle: String
    private let cancelTitle: String?
    private let confirmAction: (() -> Void)?
    private let cancelAction: (() -> Void)?
    
    init(
        title: String,
        message: String,
        confirmTitle: String = "확인",
        cancelTitle: String? = nil,
        confirmAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil
    ) {
        self.alertTitle = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupActions()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        animateIn()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(separatorLine)
        containerView.addSubview(confirmButton)
        
        if cancelTitle != nil {
            containerView.addSubview(buttonSeparator)
            containerView.addSubview(cancelButton)
        }
    }
    
    private func setupConstraints() {
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        if cancelTitle != nil {
            cancelButton.snp.makeConstraints {
                $0.top.equalTo(separatorLine.snp.bottom)
                $0.leading.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(56)
                $0.width.equalTo(confirmButton)
            }
            
            buttonSeparator.snp.makeConstraints {
                $0.leading.equalTo(cancelButton.snp.trailing)
                $0.top.equalTo(separatorLine.snp.bottom)
                $0.bottom.equalToSuperview()
                $0.width.equalTo(1)
            }
            
            confirmButton.snp.makeConstraints {
                $0.top.equalTo(separatorLine.snp.bottom)
                $0.leading.equalTo(buttonSeparator.snp.trailing)
                $0.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(56)
            }
        } else {
            confirmButton.snp.makeConstraints {
                $0.top.equalTo(separatorLine.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.height.equalTo(56)
            }
        }
    }
    
    private func setupActions() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func configure() {
        titleLabel.text = alertTitle
        messageLabel.text = message
        confirmButton.setTitle(confirmTitle, for: .normal)
        
        if let cancelTitle = cancelTitle {
            cancelButton.setTitle(cancelTitle, for: .normal)
        }
    }
    
    @objc private func dimmedViewTapped() {
        dismiss(animated: true)
    }
    
    @objc private func confirmButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.confirmAction?()
        }
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.cancelAction?()
        }
    }
    
    private func animateIn() {
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }
}

extension CustomAlertViewController {
    
    /// 기본 Alert (확인 버튼만)
    static func show(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "확인",
        confirmAction: (() -> Void)? = nil
    ) {
        let alert = CustomAlertViewController(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            confirmAction: confirmAction
        )
        
        viewController.present(alert, animated: true)
    }
    
    /// 2버튼 Alert (취소 + 확인)
    static func showWithCancel(
        on viewController: UIViewController,
        title: String,
        message: String,
        confirmTitle: String = "확인",
        cancelTitle: String = "취소",
        confirmAction: (() -> Void)? = nil,
        cancelAction: (() -> Void)? = nil
    ) {
        let alert = CustomAlertViewController(
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            cancelTitle: cancelTitle,
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
        
        viewController.present(alert, animated: true)
    }
}
