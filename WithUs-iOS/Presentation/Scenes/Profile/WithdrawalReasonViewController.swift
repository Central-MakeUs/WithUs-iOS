//
//  WithdrawalReasonViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import UIKit
import SnapKit
import Then
import ReactorKit
import RxSwift

final class WithdrawalReasonViewController: BaseViewController, View {
    
    weak var coordinator: ProfileCoordinator?
    var disposeBag: DisposeBag = DisposeBag()
    
    private let titleLabel = UILabel().then {
        $0.text = "떠나는 이유를 선택해 주세요"
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "서비스를 이용하면서 느낀 점을 공유해 주시면\n더 나은 서비스를 제공할 수 있도록 노력하겠습니다"
        $0.font = UIFont.pretendard16Regular
        $0.textColor = UIColor.gray500
        $0.numberOfLines = 0
    }
    
    private let reasonStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.distribution = .fillEqually
    }
    
    private let reason1Button = ReasonButton(title: "앱을 자주 사용하지 않아요")
    private let reason2Button = ReasonButton(title: "사용 방법이 복잡하거나 불편했어요")
    private let reason3Button = ReasonButton(title: "연인과 헤어졌어요")
    private let reason4Button = ReasonButton(title: "제가 필요로 하는 기능이 부족했어요")
    private let reason5Button = ReasonButton(title: "기타")
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }
    
    private let cancelButton = UIButton().then {
        $0.setTitle("유지하기", for: .normal)
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.gray700.cgColor
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 8
    }
    
    private let withdrawalButton = UIButton().then {
        $0.setTitle("탈퇴하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    // MARK: - Properties
    private var selectedReason: ReasonButton?
    private var reasonButtons: [ReasonButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reasonButtons = [reason1Button, reason2Button, reason3Button, reason4Button, reason5Button]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        
        let attributed = NSAttributedString(
            string: "회원 탈퇴",
            attributes: [
                .foregroundColor: UIColor.gray900,
                .font: UIFont.pretendard18SemiBold
            ]
        )
        navigationItem.titleView = UILabel().then {
            $0.attributedText = attributed
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(reasonStackView)
        
        reasonStackView.addArrangedSubview(reason1Button)
        reasonStackView.addArrangedSubview(reason2Button)
        reasonStackView.addArrangedSubview(reason3Button)
        reasonStackView.addArrangedSubview(reason4Button)
        reasonStackView.addArrangedSubview(reason5Button)
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(withdrawalButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        reasonStackView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        reason1Button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        reason2Button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        reason3Button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        reason4Button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        reason5Button.addTarget(self, action: #selector(reasonButtonTapped(_:)), for: .touchUpInside)
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: ProfileReactor) {
        reactor.state.map{ $0.deleteSuccess }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(on: MainScheduler.instance)
            .bind(with: self, onNext: { strongSelf, _ in
                strongSelf.coordinator?.handleWithdrawal()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    @objc private func reasonButtonTapped(_ sender: ReasonButton) {
        selectedReason?.isSelected = false
        
        if selectedReason == sender {
            selectedReason = nil
            updateWithdrawalButtonState()
            return
        }
        
        sender.isSelected = true
        selectedReason = sender
        
        updateWithdrawalButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func withdrawalButtonTapped() {
        guard let selectedReason = selectedReason else { return }
        
        print("선택된 탈퇴 사유: \(selectedReason.titleLabel?.text ?? "")")
        reactor?.action.onNext(.deleteAccount)
    }
    
    // MARK: - Private Methods
    private func updateWithdrawalButtonState() {
        let isEnabled = selectedReason != nil
        withdrawalButton.isEnabled = isEnabled
        withdrawalButton.backgroundColor = isEnabled ? UIColor.abled : UIColor.disabled
    }
}
