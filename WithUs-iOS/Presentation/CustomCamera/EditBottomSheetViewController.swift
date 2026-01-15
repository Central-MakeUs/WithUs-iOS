//
//  EditBottomSheetViewController.swift
//  WithUs-iOS
//
//  Created by Claude on 1/15/26.
//

import UIKit
import SnapKit
import Then

protocol EditBottomSheetDelegate: AnyObject {
    func didSelectText()
    func didSelectLocation()
    func didSelectMusic()
    func didSelectSticker()
    func didSelectEmoji()
    func didSelectThumbsDown()
    func didSelectBestHairstyle()
    func didSelectFire()
}

class EditBottomSheetViewController: UIViewController {
    
    weak var delegate: EditBottomSheetDelegate?
    
    private let dimmedView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        $0.alpha = 0
    }
    
    private let bottomSheetView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    private let handleBar = UIView().then {
        $0.backgroundColor = UIColor.systemGray4
        $0.layer.cornerRadius = 2.5
    }
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .black
    }
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.tintColor = .systemCyan
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var textButton = createOptionButton(
        emoji: "Aa",
        title: "텍스트",
        hasNotification: true
    )
    
    private lazy var locationButton = createOptionButton(
        icon: "location.fill",
        title: "위치"
    )
    
    private lazy var musicButton = createOptionButton(
        icon: "music.note",
        title: "음악"
    )
    
    private lazy var stickerButton = createOptionButton(
        emoji: "😊",
        title: "준맞탱"
    )
    
    private lazy var emojiButton = createOptionButton(
        emoji: "👍",
        title: "붐업"
    )
    
    private lazy var thumbsDownButton = createOptionButton(
        emoji: "👎",
        title: "붐따"
    )
    
    private lazy var bestHairstyleButton = createOptionButton(
        emoji: "🥳",
        title: "최고의 하루"
    )
    
    private lazy var fireButton = createOptionButton(
        emoji: "🔥",
        title: "오늘도 화이팅"
    )
    
    private var bottomSheetViewBottomConstraint: Constraint?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGestures()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showBottomSheet()
    }
    
    private func setupUI() {
        view.addSubview(dimmedView)
        view.addSubview(bottomSheetView)
        
        bottomSheetView.addSubview(handleBar)
        bottomSheetView.addSubview(closeButton)
        bottomSheetView.addSubview(profileImageView)
        
        bottomSheetView.addSubview(textButton)
        bottomSheetView.addSubview(locationButton)
        bottomSheetView.addSubview(musicButton)
        bottomSheetView.addSubview(stickerButton)
        bottomSheetView.addSubview(emojiButton)
        bottomSheetView.addSubview(thumbsDownButton)
        bottomSheetView.addSubview(bestHairstyleButton)
        bottomSheetView.addSubview(fireButton)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        bottomSheetView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(350)
            self.bottomSheetViewBottomConstraint = $0.bottom.equalTo(view.snp.bottom).offset(350).constraint
        }
        
        handleBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(5)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.size.equalTo(24)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(20)
            $0.right.equalToSuperview().inset(24)
            $0.size.equalTo(60)
        }
        
        textButton.snp.makeConstraints {
            $0.top.equalTo(handleBar.snp.bottom).offset(60)
            $0.left.equalToSuperview().offset(24)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        locationButton.snp.makeConstraints {
            $0.centerY.equalTo(textButton)
            $0.left.equalTo(textButton.snp.right).offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        musicButton.snp.makeConstraints {
            $0.centerY.equalTo(textButton)
            $0.left.equalTo(locationButton.snp.right).offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        stickerButton.snp.makeConstraints {
            $0.top.equalTo(textButton.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        emojiButton.snp.makeConstraints {
            $0.centerY.equalTo(stickerButton)
            $0.left.equalTo(stickerButton.snp.right).offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        thumbsDownButton.snp.makeConstraints {
            $0.centerY.equalTo(stickerButton)
            $0.left.equalTo(emojiButton.snp.right).offset(16)
            $0.width.equalTo(100)
            $0.height.equalTo(60)
        }
        
        bestHairstyleButton.snp.makeConstraints {
            $0.top.equalTo(stickerButton.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.width.equalTo(140)
            $0.height.equalTo(60)
        }
        
        fireButton.snp.makeConstraints {
            $0.centerY.equalTo(bestHairstyleButton)
            $0.left.equalTo(bestHairstyleButton.snp.right).offset(16)
            $0.width.equalTo(160)
            $0.height.equalTo(60)
        }
    }
    
    private func setupGestures() {
        let dimmedTap = UITapGestureRecognizer(target: self, action: #selector(dimmedViewTapped))
        dimmedView.addGestureRecognizer(dimmedTap)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        textButton.addTarget(self, action: #selector(textButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        musicButton.addTarget(self, action: #selector(musicButtonTapped), for: .touchUpInside)
        stickerButton.addTarget(self, action: #selector(stickerButtonTapped), for: .touchUpInside)
        emojiButton.addTarget(self, action: #selector(emojiButtonTapped), for: .touchUpInside)
        thumbsDownButton.addTarget(self, action: #selector(thumbsDownButtonTapped), for: .touchUpInside)
        bestHairstyleButton.addTarget(self, action: #selector(bestHairstyleButtonTapped), for: .touchUpInside)
        fireButton.addTarget(self, action: #selector(fireButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func dimmedViewTapped() {
        hideBottomSheet()
    }
    
    @objc private func closeButtonTapped() {
        hideBottomSheet()
    }
    
    @objc private func textButtonTapped() {
        let delegate = self.delegate
        hideBottomSheet() {
            delegate?.didSelectText()
        }
    }
    
    @objc private func locationButtonTapped() {
        delegate?.didSelectLocation()
        hideBottomSheet()
    }
    
    @objc private func musicButtonTapped() {
        delegate?.didSelectMusic()
        hideBottomSheet()
    }
    
    @objc private func stickerButtonTapped() {
        delegate?.didSelectSticker()
        hideBottomSheet()
    }
    
    @objc private func emojiButtonTapped() {
        delegate?.didSelectEmoji()
        hideBottomSheet()
    }
    
    @objc private func thumbsDownButtonTapped() {
        delegate?.didSelectThumbsDown()
        hideBottomSheet()
    }
    
    @objc private func bestHairstyleButtonTapped() {
        delegate?.didSelectBestHairstyle()
        hideBottomSheet()
    }
    
    @objc private func fireButtonTapped() {
        delegate?.didSelectFire()
        hideBottomSheet()
    }
    
    private func showBottomSheet() {
        bottomSheetViewBottomConstraint?.update(offset: 0)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideBottomSheet(completion: (() -> Void)? = nil) {
        bottomSheetViewBottomConstraint?.update(offset: 350)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.dismiss(animated: false) {
                completion?()
            }
        }
    }
    
    private func createOptionButton(emoji: String? = nil, icon: String? = nil, title: String, hasNotification: Bool = false) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .black
        button.layer.cornerRadius = 30
        
        // 컨테이너 스택뷰
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.isUserInteractionEnabled = false
        
        // 아이콘 또는 이모지
        if let emoji = emoji {
            let iconLabel = UILabel()
            iconLabel.text = emoji
            iconLabel.font = .systemFont(ofSize: 20)
            stackView.addArrangedSubview(iconLabel)
        } else if let icon = icon {
            let imageView = UIImageView(image: UIImage(systemName: icon))
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            imageView.snp.makeConstraints {
                $0.size.equalTo(20)
            }
            stackView.addArrangedSubview(imageView)
        }
        
        // 텍스트 레이블
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        stackView.addArrangedSubview(titleLabel)
        
        button.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        // 알림 뱃지
        if hasNotification {
            let badge = UIView()
            badge.backgroundColor = .red
            badge.layer.cornerRadius = 8
            badge.isUserInteractionEnabled = false
            
            let badgeLabel = UILabel()
            badgeLabel.text = "1"
            badgeLabel.textColor = .white
            badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
            badgeLabel.textAlignment = .center
            
            badge.addSubview(badgeLabel)
            button.addSubview(badge)
            
            badgeLabel.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            badge.snp.makeConstraints {
                $0.top.equalToSuperview().offset(-4)
                $0.left.equalToSuperview().offset(-4)
                $0.size.equalTo(16)
            }
        }
        
        return button
    }
}
