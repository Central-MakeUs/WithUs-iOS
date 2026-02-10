//
//  ModifyAccountViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/27/26.
//

import UIKit
import SnapKit
import Then
import SwiftUI
import ReactorKit
import RxSwift

final class ModifyAccountViewController: BaseViewController, ReactorKit.View {
    var disposeBag: DisposeBag = DisposeBag()
    weak var coordinator: ProfileCoordinator?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    struct SettingItem {
        let title: String
        let id: AccountCategory
    }
    
    enum AccountCategory {
        case logout
        case delete
    }
    
    private let sections: [SettingItem] = [
        SettingItem(title: "로그아웃", id: .logout),
        SettingItem(title: "회원탈퇴", id: .delete)
    ]
    
    private var cellRegistration: UICollectionView.CellRegistration<UICollectionViewCell, SettingItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCellRegistration()
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
    
    private func setupCellRegistration() {
        cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, SettingItem> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                SettingCellView(title: item.title)
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
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 0
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        return layout
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(collectionView)
    }
    
    override func setupConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setNavigation() {
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
        self.navigationItem.title = "계정 관리"
    }
    
    func bind(reactor: ProfileReactor) {
        reactor.state.map{ $0.logoutSuccess }
            .distinctUntilChanged()
            .filter { $0 }
            .subscribe(on: MainScheduler.instance)
            .bind(with: self, onNext: { strongSelf, _ in
                strongSelf.coordinator?.handleLogout()
            })
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
}

extension ModifyAccountViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.item]
        
        return collectionView.dequeueConfiguredReusableCell(
            using: cellRegistration,
            for: indexPath,
            item: item
        )
    }
}

extension ModifyAccountViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.item]
        print("선택된 항목: \(item.title), ID: \(item.id)")
        switch item.id {
        case .logout:
            CustomAlertViewController
                .showWithCancel(
                    on: self,
                    title: "로그아웃 하시겠어요?",
                    message: "언제든 다시 로그인해서\n이어서 사용할 수 있어요.",
                    confirmTitle: "로그아웃",
                    cancelTitle: "취소",
                    confirmAction: { [weak self] in
                        self?.reactor?.action.onNext(.logoutAccount)
                    }
                )
        case .delete:
            coordinator?.showWithdrawal()
        }
    }
}
