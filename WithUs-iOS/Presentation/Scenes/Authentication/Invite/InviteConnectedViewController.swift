//
//  InviteConnectedViewController.swift
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

final class InviteConnectedViewController: BaseViewController, View {
    
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
        $0.text = "커플 연결 완료!"
    }
    
    private let subTitleLabel = UILabel().then {
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.textAlignment = .center
        $0.text = "둘만의 사진 기록을 시작해 보세요"
    }
    
    private let imageView = UIImageView().then {
        $0.image = UIImage(named: "invite_complete")
        $0.backgroundColor = .white
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
    }
    
    private let startButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 8
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
        view.addSubview(startButton)
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subTitleLabel)
    }
    
    override func setupConstraints() {
        titleStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(108)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleStackView.snp.bottom).offset(42)
            $0.size.equalTo(200)
            $0.centerX.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    override func setNavigation() {
        navigationItem.hidesBackButton = true
    }
    
    func bind(reactor: InviteInputCodeReactor) {
        reactor.state.map { $0.previewData }
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, data in
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
    
    @objc private func startTapped() {
        coordinator?.didComplete()
    }
}


