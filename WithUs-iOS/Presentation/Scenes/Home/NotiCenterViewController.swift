//
//  NotiCenterViewController.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/10/26.
//

import Foundation
import UIKit
import SnapKit
import Then
import ReactorKit

final class NotiCenterViewController: BaseViewController, View{
    var disposeBag: DisposeBag = DisposeBag()
    private let noRequestView = NoRequestNotiView()
    private let emptyView = EmptyNotiView()
    private let tableView = NotiTableView()
    
    private var noti: [NotiCenterItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        reactor?.action.onNext(.loadInitialData)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        checkNotificationPermissionAndUpdateUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func setupUI() {
        super.setupUI()
        view.addSubview(noRequestView)
        view.addSubview(emptyView)
        view.addSubview(tableView)
    }
    
    override func setupConstraints() {
        noRequestView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(89)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(176)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func setNavigation() {
        let titleLabel = UILabel()
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.pretendard20SemiBold,
            .foregroundColor: UIColor.black
        ]
        titleLabel.attributedText = NSAttributedString(string: "알림", attributes: attributes)
        titleLabel.sizeToFit()
        navigationItem.titleView = titleLabel
         
        setLeftBarButton(image: UIImage(named: "ic_back"))
    }
    
    func bind(reactor: NotiCenterReactor) {
        reactor.state.map { $0.noti }
            .distinctUntilChanged { $0.count == $1.count }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] notiItems in
                guard let self else { return }
                self.updateList(notiItems)
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
    
    private func updateList(_ noti: [NotiCenterItem]) {
        self.noti = noti
        self.updateViewState(hasItems: !noti.isEmpty)
    }
    
    private func checkNotificationPermissionAndUpdateUI() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                if settings.authorizationStatus == .authorized {
                    self.updateViewState(hasItems: !self.noti.isEmpty)
                } else {
                    self.showNoRequestView()
                }
            }
        }
    }
    
    private func updateViewState(hasItems: Bool) {
        noRequestView.isHidden = true
        emptyView.isHidden = hasItems
        tableView.isHidden = !hasItems
        
        if hasItems {
            tableView.configure(with: noti)
        }
    }
    
    private func showNoRequestView() {
        noRequestView.isHidden = false
        emptyView.isHidden = true
        tableView.isHidden = true
    }

}

extension NotiCenterViewController: NotiTableViewCellDelegate {
    func didSelect(_ item: NotiCenterItem) {
        guard let deepLink = item.deepLink else {
            return
        }
        DeepLinkHandler.shared.handle(deepLink: deepLink)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            sceneDelegate.appCoordinator?.handlePendingDeepLinkIfNeeded()
        }
    }

    func didScrollToBottom() {
        reactor?.action.onNext(.loadMoreData)
    }
}
