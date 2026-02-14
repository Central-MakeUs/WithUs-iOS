//
//  InviteCodeViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/10/26.
//

import UIKit
import Then
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class InviteCodeViewController: BaseViewController, View {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    weak var coordinator: InviteCoordinator?
    
    private let pinLength = 8
    var pinCode: String = "" {
        didSet {
            updatePinDisplay()
        }
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.pretendard24Bold
        $0.textAlignment = .center
        $0.numberOfLines = 2
        $0.text = "상대방에게 코드를\n공유해서 초대해 보세요"
        $0.textColor = UIColor.gray900
    }
    
    private let pinStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .fillEqually
    }
    
    private let duplicateBtn = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "코드 복사"
        config.image = UIImage(named: "ic_duplicate")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = UIColor.gray900
        config.background.backgroundColor = UIColor.gray50
        config.background.strokeColor = UIColor.gray700
        config.background.strokeWidth = 1
        config.background.cornerRadius = 8
        
        $0.configuration = config
    }
    
    private let linkBtn = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "링크 공유"
        config.baseForegroundColor = .white
        config.image = UIImage(named: "ic_link")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.background.backgroundColor = UIColor.gray900
        config.background.cornerRadius = 8
        
        $0.configuration = config
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .center
    }
    
    private var pinDigitViews: [PinDigitView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        reactor?.action.onNext(.getInvitationCode)
    }
    
    init(reactor: InviteCodeReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(titleLabel)
        view.addSubview(pinStackView)
        for _ in 0..<pinLength {
            let digitView = PinDigitView()
            pinDigitViews.append(digitView)
            pinStackView.addArrangedSubview(digitView)
        }
        view.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(duplicateBtn)
        buttonStackView.addArrangedSubview(linkBtn)
    }
    
    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            $0.centerX.equalToSuperview()
        }
        
        pinStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(64)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(75)
        }
        
        
        buttonStackView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        duplicateBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
        
        linkBtn.snp.makeConstraints {
            $0.height.equalTo(56)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    override func setupActions() {
        duplicateBtn.addTarget(self, action: #selector(duplicateBtnTapped), for: .touchUpInside)
        linkBtn.addTarget(self, action: #selector(linkBtnTapped), for: .touchUpInside)
    }
    
    func bind(reactor: InviteCodeReactor) {
        reactor.state
            .map { $0.invitationCode }
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, code in
                owner.pinCode = code
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
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func duplicateBtnTapped() {
        guard !pinCode.isEmpty else {
            ToastView.show(message: "복사에 실패했어요.")
            return
        }
        
        UIPasteboard.general.string = pinCode
        ToastView.show(message: "코드가 성공적으로 복사 되었어요")
    }
    
    @objc private func linkBtnTapped() {
//        let imageToShare: UIImage = UIImage(named: "ic_duplicate")!
//        let urlToShare: String = "https://velog.io/@go90js"
//        let textToShare: String = "고라니"
//        
//        let activityViewController = UIActivityViewController(activityItems: [imageToShare, urlToShare, textToShare], applicationActivities: nil)
//        present(activityViewController, animated: true)
    }
    
    private func updatePinDisplay() {
        let digits = Array(pinCode)
        
        for (index, digitView) in pinDigitViews.enumerated() {
            if index < digits.count {
                let digit = String(digits[index])
                digitView.configure(isFilled: true, digit: digit)
            } else {
                digitView.configure(isFilled: false, digit: nil)
            }
        }
    }
    
}

