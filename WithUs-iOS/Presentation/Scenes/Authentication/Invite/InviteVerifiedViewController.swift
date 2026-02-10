//
//  InviteVerifiedViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/14/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift
import RxCocoa

final class InviteVerifiedViewController: BaseViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    weak var coordinator: InviteCoordinatorProtocol?
    
    private let titleStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 16
        $0.alignment = .center
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "??? 님이\n??? 님을 초대했어요!"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "초대를 수락하면, 두 사람의 기록이 이어져요"
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "need_invite")
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
    }
    
    private let acceptButton = UIButton().then {
        $0.setTitle("초대 수락하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
    }
    
    private let laterButton = UIButton().then {
        $0.setTitle("다음에 할래요", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.backgroundColor = UIColor.gray50
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    init(reactor: InviteInputCodeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        view.addSubview(titleStackView)
        view.addSubview(imageView)
        view.addSubview(buttonStackView)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
        
        buttonStackView.addArrangedSubview(acceptButton)
        buttonStackView.addArrangedSubview(laterButton)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(108)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom)
            $0.size.equalTo(200)
            $0.centerX.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        acceptButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        laterButton.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    override func setupActions() {
        acceptButton.addTarget(self, action: #selector(acceptBtnTapped), for: .touchUpInside)
        laterButton.addTarget(self, action: #selector(laterBtnTapped), for: .touchUpInside)
    }
    
    override func setNavigation() {
        navigationItem.hidesBackButton = true
    }
    
    func bind(reactor: InviteInputCodeReactor) {
        reactor.state.map { $0.coupleId }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, id in
                if !id.isEmpty {
                    owner.coordinator?.showConnected()
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.previewData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
                let myName = data.myName
                let senderName = data.senderName
                owner.titleLabel.text = "\(senderName) 님이\n\(myName) 님을 초대했어요!"
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isLoading }
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(with: self) { strongSelf, isLoading in
                isLoading ? strongSelf.showLoading() : strongSelf.hideLoading()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, message in
                ToastView.show(message: message)
            }
            .disposed(by: disposeBag)
    }
    
    @objc private func acceptBtnTapped() {
        guard let reactor, let data = reactor.currentState.previewData else { return }
        
        let code = data.inviteCode
        reactor.action.onNext(.acceptInvite(code))
    }
    
    @objc private func laterBtnTapped() {
        coordinator?.didComplete()
    }
}


