//
//  WithdrawalViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//
import UIKit
import SnapKit
import Then

final class WithdrawalViewController: BaseViewController {
    
    weak var coordinator: ProfileCoordinator?
    
    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.text = "정말 WITHUS를 떠나시나요?"
        $0.font = UIFont.pretendard24Bold
        $0.textColor = UIColor.gray900
        $0.textAlignment = .center
    }
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = UIColor.gray200
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let warningTitleView = UIView()
    
    private let warningIconView = UIView().then {
        $0.backgroundColor = UIColor.gray900
        $0.layer.cornerRadius = 10
    }
    
    private let warningIconLabel = UILabel().then {
        $0.text = "!"
        $0.font = UIFont.pretendard14SemiBold
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let warningTitleLabel = UILabel().then {
        $0.text = "회원 탈퇴 전 꼭 확인해 주세요!"
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let warningDetail1StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon1 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private lazy var warning1Label = UILabel().then { [weak self] in
        guard let self else { return }
        let attributedText = createHighlightedAttributedString(
            fullText: "연결된 상대가 있는 경우,\n마이>연결 정보>연결 해제하기를 해야 탈퇴가 가능해요.",
            highlightText: "마이>연결 정보>연결 해제하기",
            highlightColor: UIColor.gray900,
            highlightFont: UIFont.pretendard14SemiBold,
            normalColor: UIColor.gray900,
            normalFont: UIFont.pretendard14Regular
        )
        $0.attributedText = attributedText
        $0.numberOfLines = 0
    }
    
    private let warningDetail2StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon2 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private let warning2Label = UILabel().then {
        $0.text = "탈퇴한 뒤 재가입하는 경우,\n이전 계정 데이터는 복원되지 않아요."
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    private let warningDetail3StackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .top
    }
    
    private let dotIcon3 = UILabel().then {
        $0.text = "•"
        $0.font = UIFont.pretendard18Regular
        $0.textColor = UIColor.gray900
    }
    
    private let warning3Label = UILabel().then {
        $0.text = "탈퇴는 즉시 처리되며 철회할 수 없어요."
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray900
        $0.numberOfLines = 0
    }
    
    private let warningStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 12
        $0.alignment = .leading
    }
    
    private let agreementButton = UIButton().then {
        $0.contentHorizontalAlignment = .leading
    }
    
    private let checkboxImageView = UIImageView().then {
        $0.image = UIImage(named: "ic_no_check")
        $0.contentMode = .scaleAspectFit
    }
    
    private let agreementLabel = UILabel().then {
        $0.text = "유의사항을 모두 확인하였으며, 회원탈퇴 시 활동 내역의 소멸 및 데이터 복원 불가에 동의합니다."
        $0.font = UIFont.pretendard14Regular
        $0.textColor = UIColor.gray700
        $0.numberOfLines = 0
    }
    
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
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.pretendard16SemiBold
        $0.backgroundColor = UIColor.disabled
        $0.layer.cornerRadius = 8
        $0.isEnabled = false
    }
    
    // MARK: - Properties
    private var isAgreed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        view.addSubview(imageView)
        view.addSubview(warningTitleView)
        
        warningTitleView.addSubview(warningIconView)
        warningIconView.addSubview(warningIconLabel)
        warningTitleView.addSubview(warningTitleLabel)
        
        // Warning Detail 1
        warningDetail1StackView.addArrangedSubview(dotIcon1)
        warningDetail1StackView.addArrangedSubview(warning1Label)
        
        // Warning Detail 2
        warningDetail2StackView.addArrangedSubview(dotIcon2)
        warningDetail2StackView.addArrangedSubview(warning2Label)
        
        // Warning Detail 3
        warningDetail3StackView.addArrangedSubview(dotIcon3)
        warningDetail3StackView.addArrangedSubview(warning3Label)
        
        // Warning StackView
        warningStackView.addArrangedSubview(warningDetail1StackView)
        warningStackView.addArrangedSubview(warningDetail2StackView)
        warningStackView.addArrangedSubview(warningDetail3StackView)
        
        view.addSubview(warningStackView)
        
        view.addSubview(agreementButton)
        agreementButton.addSubview(checkboxImageView)
        agreementButton.addSubview(agreementLabel)
        
        view.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(withdrawalButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(22)
            $0.centerX.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(167)
        }
        
        warningTitleView.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(24)
        }
        
        warningIconView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        warningIconLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        warningTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(warningIconView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        warningStackView.snp.makeConstraints {
            $0.top.equalTo(warningTitleView.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        warningDetail1StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        warningDetail2StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        warningDetail3StackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
        }
        
        agreementButton.snp.makeConstraints {
            $0.top.equalTo(warningStackView.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        checkboxImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        agreementLabel.snp.makeConstraints {
            $0.leading.equalTo(checkboxImageView.snp.trailing).offset(8)
            $0.trailing.top.bottom.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-12)
            $0.height.equalTo(56)
        }
    }
    
    override func setupActions() {
        agreementButton.addTarget(self, action: #selector(agreementButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func agreementButtonTapped() {
        isAgreed.toggle()
        updateAgreementUI()
        updateWithdrawalButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func withdrawalButtonTapped() {
        guard isAgreed else { return }
        CustomAlertViewController
            .showWithCancel(
                on: self,
                title: "아직 연결 해제가 안되었어요!",
                message: "현재 상대방과 연결된 상태에요.\n회원 탈퇴를 위해 연결을 해제하시겠어요?",
                confirmTitle: "해제하러 가기",
                cancelTitle: "취소",
                confirmAction: { [weak self] in
                    self?.coordinator?.showConnectSettings()
                }
            )
    }
    
    // MARK: - Private Methods
    private func updateAgreementUI() {
        let imageName = isAgreed ? "ic_check" : "ic_no_check"
        checkboxImageView.image = UIImage(named: imageName)
    }
    
    private func updateWithdrawalButtonState() {
        withdrawalButton.isEnabled = isAgreed
        withdrawalButton.backgroundColor = isAgreed ? UIColor.abled : UIColor.disabled
    }
    
    func createHighlightedAttributedString(
        fullText: String,
        highlightText: String,
        highlightColor: UIColor,
        highlightFont: UIFont,
        normalColor: UIColor,
        normalFont: UIFont
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        attributedString.addAttributes([
            .font: normalFont,
            .foregroundColor: normalColor
        ], range: NSRange(location: 0, length: fullText.count))
        
        if let range = fullText.range(of: highlightText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes([
                .foregroundColor: highlightColor,
                .font: highlightFont
            ], range: nsRange)
        }
        
        return attributedString
    }
}
