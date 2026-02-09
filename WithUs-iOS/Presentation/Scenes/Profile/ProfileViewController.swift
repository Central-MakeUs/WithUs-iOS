//
//  ProfileViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/16/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import ReactorKit
import RxSwift
import Kingfisher

final class ProfileViewController: BaseViewController, ReactorKit.View {
    weak var coordinator: ProfileCoordinator?
    var disposeBag: DisposeBag = DisposeBag()
    
    private let profileView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let profileImageView = UIImageView().then {
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        $0.image = UIImage(systemName: "person.fill", withConfiguration: config)
        $0.tintColor = .white
        $0.contentMode = .center
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .gray200
    }
    
    private let editButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.title = "프로필 편집"
        config.baseForegroundColor = .gray500
        config.background.backgroundColor = .white
        config.background.cornerRadius = 14
        config.background.strokeColor = .gray300
        config.background.strokeWidth = 1
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 8,
            leading: 16,
            bottom: 8,
            trailing: 16
        )
        
        $0.configuration = config
        $0.titleLabel?.font = .pretendard14Regular
    }
    
    private let nicknameLabel = UILabel().then {
        $0.text = "닉네임을 입력해 주세요"
        $0.font = UIFont.pretendard18SemiBold
        $0.textColor = .gray900
    }
    
    private let dateLabel = UILabel().then {
        $0.text = "2024년 10월 6일 가입"
        $0.font = UIFont.pretendard12Regular
        $0.textColor = .gray500
    }
    
    private let infoStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 0
    }
    
    private let profileStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 12
    }
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellRegistration()
    }
    
    func bind(reactor: ProfileReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        reactor.state
            .compactMap { $0.user }
            .observe(on: MainScheduler.instance)
            .bind(with: self) { strongSelf, user in
                strongSelf.nicknameLabel.text = user.nickname
                
                if let profileUrlString = user.profileImageUrl,
                   let url = URL(string: profileUrlString) {
                    strongSelf.profileImageView.kf.setImage(
                        with: url,
                        placeholder: nil,
                        options: [
                            .transition(.fade(0.2)),
                            .cacheOriginalImage
                        ]
                    )
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userStatus }
            .distinctUntilChanged { $0 == $1 }
            .subscribe()
            .disposed(by: disposeBag)
    }
    
    struct SettingItem {
        let title: String
        let id: MyProfileCategory
    }
    
    enum MyProfileCategory {
        case notification
        case keyword
        case account
        case connect
        case kakao
        case review
        case terms
        case privacy
    }
    
    private let sections: [(title: String, items: [SettingItem])] = [
        ("설정", [
            SettingItem(title: "알림", id: .notification),
            SettingItem(title: "일상 키워드 관리", id: .keyword),
            SettingItem(title: "계정 관리", id: .account)
        ]),
        ("정보", [
            SettingItem(title: "커플 연결 정보", id: .connect),
            SettingItem(title: "카카오 채널 문의하기", id: .kakao),
            SettingItem(title: "앱 리뷰 남기기", id: .review),
            SettingItem(title: "이용 약관", id: .terms),
            SettingItem(title: "개인정보 처리방침", id: .privacy)
        ])
    ]
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, SettingItem>!
    private var headerRegistration: UICollectionView.SupplementaryRegistration<UICollectionViewCell>!
    

    
    private func setupCellRegistration() {
        cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, SettingItem> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SettingCellView(title: item.title)
            }
            .margins(.all, 0)
            .background(Color(uiColor: .white))
        }
        
        headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] supplementaryView, elementKind, indexPath in
            guard let self = self else { return }
            let sectionTitle = self.sections[indexPath.section].title
            
            supplementaryView.contentConfiguration = UIHostingConfiguration {
                SectionHeaderView(title: sectionTitle)
            }
            .margins(.all, 0)
            .background(Color(uiColor: .white))
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(56)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(profileView)
        
        profileView.addSubview(profileStackView)
        profileView.addSubview(editButton)
        
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(infoStackView)
        
        infoStackView.addArrangedSubview(nicknameLabel)
        infoStackView.addArrangedSubview(dateLabel)
        
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        profileView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(18.5)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(40)
        }
        
        profileStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
        
        editButton.snp.makeConstraints {
            $0.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(37)
        }
        
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(17.5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func setNavigation() {
        let attributedText = NSAttributedString(
            string: "마이",
            attributes: [.foregroundColor: UIColor.gray900, .font: UIFont.pretendard24Bold]
        )
        setLeftBarButton(attributedTitle: attributedText)
    }
    
    override func setupActions() {
        editButton.addTarget(self, action: #selector(modifyProfile), for: .touchUpInside)
    }
    
    @objc private func modifyProfile() {
        coordinator?.showProfileModification()
    }
    
    private func formattedJoinedText(from user: User) -> String? {
        if let createdAt = (user as AnyObject).value(forKey: "createdAt") as? String {
            let comps = createdAt.split(separator: "-").compactMap { Int($0) }
            if comps.count == 3 {
                return "\(comps[0])년 \(comps[1])월 \(comps[2])일 가입"
            }
        }
        return nil
    }
}

extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return collectionView.dequeueConfiguredReusableSupplementary(
            using: headerRegistration,
            for: indexPath
        )
    }
}

extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.item]
        print("선택된 항목: \(item.title), ID: \(item.id)")
        switch item.id {
        case .keyword:
            self.coordinator?.showKeywordModification()
        case .account:
            self.coordinator?.showAccountModification()
        case .connect:
            guard let status = reactor?.currentState.userStatus else { return }
            if status == .completed {
                self.coordinator?.showCancleConnect()
            } else if status == .needCoupleConnect {
                self.coordinator?.showConnectCoupleFlow()
            } else {
                ToastView.show(message: "회원가입을 진행해주세요.", icon: nil, position: .bottom)
            }
        case .kakao:
            openExternalBrowser(urlStr: "https://open.kakao.com/o/svs9Bjfi")
        case .privacy:
            openExternalBrowser(urlStr: "https://mesquite-castanet-719.notion.site/WITHUS-2e44b00730818039a6d0cf0adf89168c?source=copy_link")
        case .terms:
            openExternalBrowser(urlStr: "https://mesquite-castanet-719.notion.site/WITHUS-2e44b0073081804bb7b8dbc7e4899bc4?source=copy_link")
        default:
            break
        }
    }
}
