//
//  FilterSelectionViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/22/26.
//

import SnapKit
import Then
import UIKit
import ReactorKit
import RxSwift
import Kingfisher

enum FrameColorType {
    case black
    case white
    
    var backgroundColor: UIColor {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .black:
            return .white
        case .white:
            return .black
        }
    }
}

class FilterSelectionViewController: BaseViewController, View {
    var disposeBag = DisposeBag()
    weak var coordinator: FourCutCoordinator?
    var selectedPhotos: [UIImage] = []
    private var selectedFrameColor: FrameColorType = .white
    
    private let frameContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let gridStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
        $0.spacing = 1.83
    }
    
    private let bottomBar = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let buttonStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 18
    }
    
    private let dateLabel = UILabel().then {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        $0.text = dateFormatter.string(from: Date())
        $0.textColor = .black
        $0.font = UIFont.didot(size: 34.76, isRegular: false)
    }
    
    private let profileLabel = UILabel().then {
        $0.text = "by"
        $0.textColor = .black
        $0.font = UIFont.didot(size: 14.63, isRegular: true)
    }
    
    private let myProfileImageView = ProfileDisplayView()
    
    private let partnerProfileImageView = ProfileDisplayView()
    
    private let coupleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 1.83
        $0.alignment = .center
    }
    
    private let blackFrameButton = UIButton().then {
        $0.setTitle("검은색", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 8
    }
    
    private let whiteFrameButton = UIButton().then {
        $0.setTitle("흰색", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard18SemiBold
        $0.setTitleColor(UIColor.gray900, for: .normal)
        $0.backgroundColor = UIColor.gray200
        $0.layer.cornerRadius = 8
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor.gray50
    }
    
    private let indicatorContainer = UIView().then {
        $0.backgroundColor = UIColor.gray50
    }
    
    private let textLabel = UILabel().then {
        $0.text = "프레임 색상을 선택해주세요."
        $0.font = UIFont.pretendard16SemiBold
        $0.textColor = UIColor.gray900
    }
    
    private let doneButton = UIButton().then {
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont.pretendard14SemiBold
        $0.setTitleColor(UIColor.gray50, for: .normal)
        $0.layer.cornerRadius = 16
        $0.backgroundColor = UIColor.redWarning
    }
    
    private var photoImageViews: [UIImageView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor  = UIColor.gray50
        setupGridWithStackView()
        displayPhotos()
        updateButtonStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setNavigation() {
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        setRightBarButton(
            image: image,
            action: #selector(closeButtonTapped),
            tintColor: .black
        )
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "색상 선택", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
        setLeftBarButton(image: UIImage(systemName: "chevron.left", withConfiguration: config))
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(frameContainerView)
        view.addSubview(containerView)
        
        frameContainerView.addSubview(gridStackView)
        frameContainerView.addSubview(bottomBar)
        bottomBar.addSubview(dateLabel)
        bottomBar.addSubview(profileLabel)
        bottomBar.addSubview(coupleStackView)
        
        coupleStackView.addArrangedSubview(myProfileImageView)
        coupleStackView.addArrangedSubview(partnerProfileImageView)
        
        containerView.addSubview(indicatorContainer)
        containerView.addSubview(buttonStackView)
        
        indicatorContainer.addSubview(textLabel)
        indicatorContainer.addSubview(doneButton)
        
        buttonStackView.addArrangedSubview(whiteFrameButton)
        buttonStackView.addArrangedSubview(blackFrameButton)
    }
    
    override func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.height.equalTo(120)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicatorContainer.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        textLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
        }
        
        doneButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(16)
            $0.size.equalTo(CGSize(width: 66, height: 33))
        }
        
        buttonStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(2)
            $0.top.equalTo(indicatorContainer.snp.bottom).offset(2)
            $0.height.equalTo(56)
        }
        
        blackFrameButton.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        whiteFrameButton.snp.makeConstraints {
            $0.height.equalTo(56)
        }
        
        frameContainerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(containerView.snp.top).offset(-8)
        }
        
        gridStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9.15)
            $0.leading.trailing.equalToSuperview().inset(5.49)
        }
        
        bottomBar.snp.makeConstraints {
            $0.top.equalTo(gridStackView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().inset(9.15)
        }
        
        coupleStackView.snp.makeConstraints {
            $0.right.equalToSuperview().inset(9.15)
            $0.bottom.equalToSuperview().inset(18.29)
        }
        
        myProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        partnerProfileImageView.snp.makeConstraints {
            $0.size.equalTo(25.61)
        }
        
        profileLabel.snp.makeConstraints {
            $0.right.equalTo(coupleStackView.snp.left).offset(-7.32)
            $0.bottom.equalToSuperview().inset(18.29)
        }
    }
    
    override func setupActions() {
        super.setupActions()
        blackFrameButton.addTarget(self, action: #selector(blackFrameButtonTapped), for: .touchUpInside)
        whiteFrameButton.addTarget(self, action: #selector(whiteFrameButtonTapped), for: .touchUpInside)
        doneButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }
    
    func bind(reactor: MemoryReactor) {
        reactor.state.compactMap { $0.coupleInfo }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, data in
                strongSelf.myProfileImageView.setProfileImage(data.meProfile.profileImageUrl)
                strongSelf.partnerProfileImageView.setProfileImage(data.partnerProfile.profileImageUrl)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupGridWithStackView() {
        for row in 0..<4 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.distribution = .fillEqually
            rowStack.spacing = 1.83
            
            for col in 0..<3 {
                let imageView = UIImageView().then {
                    $0.backgroundColor = .white
                    $0.contentMode = .scaleAspectFill
                    $0.clipsToBounds = true
                }
                
                imageView.snp.makeConstraints {
                    $0.width.equalTo(imageView.snp.height)
                }
                
                photoImageViews.append(imageView)
                rowStack.addArrangedSubview(imageView)
            }
            
            gridStackView.addArrangedSubview(rowStack)
        }
    }
    
    private func displayPhotos() {
        for (index, imageView) in photoImageViews.enumerated() {
            if index < selectedPhotos.count {
                imageView.image = selectedPhotos[index]
            }
        }
    }
    
    private func updateFrameColor() {
        let backgroundColor = selectedFrameColor.backgroundColor
        let textColor = selectedFrameColor.textColor
        
        UIView.animate(withDuration: 0.3) {
            self.frameContainerView.backgroundColor = backgroundColor
            self.bottomBar.backgroundColor = backgroundColor
            self.dateLabel.textColor = textColor
        }
    }
    
    private func updateButtonStates() {
        if selectedFrameColor == .black {
            blackFrameButton.backgroundColor = .black
            blackFrameButton.setTitleColor(.white, for: .normal)
            blackFrameButton.layer.borderWidth = 0
            whiteFrameButton.backgroundColor = .white
            whiteFrameButton.setTitleColor(.gray, for: .normal)
            whiteFrameButton.layer.borderWidth = 1
            whiteFrameButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
        } else {
            blackFrameButton.backgroundColor = .white
            blackFrameButton.setTitleColor(.gray, for: .normal)
            blackFrameButton.layer.borderWidth = 1
            blackFrameButton.layer.borderColor = UIColor.systemGray.withAlphaComponent(0.3).cgColor
            
            whiteFrameButton.backgroundColor = .black
            whiteFrameButton.setTitleColor(.white, for: .normal)
            whiteFrameButton.layer.borderWidth = 0
        }
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        coordinator?.showUploadSuccessAndPopToRoot()
    }
    
    @objc private func checkButtonTapped() {
        CustomAlertViewController
            .showWithCancel(
                on: self,
                title: "수정을 종료하시겠어요?",
                message: "나가면 변경 내용이 사라질 수 있어요.\n저장이 되었는지 꼭 확인해 주세요.",
                confirmTitle: "종료하기",
                cancelTitle: "취소",
                confirmAction: { [weak self] in
                    guard let self, !selectedPhotos.isEmpty else { return }
                    self.coordinator?.showTextInputSelection(self.selectedPhotos, selectedFrameColor)
                }
            )
    }
    
    @objc private func blackFrameButtonTapped() {
        selectedFrameColor = .black
        updateButtonStates()
        updateFrameColor()
    }
    
    @objc private func whiteFrameButtonTapped() {
        selectedFrameColor = .white
        updateButtonStates()
        updateFrameColor()
    }
}
