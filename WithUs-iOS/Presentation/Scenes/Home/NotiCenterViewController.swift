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

final class NotiCenterViewController: BaseViewController {
    private let noRequestView = NoRequestNotiView()
    private let emptyView = EmptyNotiView()
    private let tableView = NotiTableView()
    
    private var notiItems: [NotiItem] = []
//    private var notiItems: [NotiItem] = [
//        NotiItem(image: UIImage(named: "ic_camera"), title: "상대방이 사진을 기다리고 있어요!", body: "지금 바로 사진을 보내볼까요?", time: "30초 전", isRead: false),
//        NotiItem(image: UIImage(named: "ic_heart"), title: "오늘의 랜덤 질문이 도착했어요!", body: "오늘의 질문에 답해볼까요?", time: "5분 전", isRead: true),
//        NotiItem(image: UIImage(named: "ic_camera"), title: "상대방이 사진을 기다리고 있어요!", body: "지금 바로 사진을 보내볼까요?", time: "12분 전", isRead: false),
//        NotiItem(image: UIImage(named: "ic_bell"), title: "새로운 메시지가 도착했어요!", body: "확인하러 가볼까요?", time: "1시간 전", isRead: true),
//        NotiItem(image: UIImage(named: "ic_camera"), title: "상대방이 사진을 기다리고 있어요!", body: "지금 바로 사진을 보내볼까요?", time: "2시간 전", isRead: true),
//        NotiItem(image: UIImage(named: "ic_heart"), title: "오늘의 랜덤 질문이 도착했어요!", body: "오늘의 질문에 답해볼까요?", time: "3시간 전", isRead: false),
//        NotiItem(image: UIImage(named: "ic_camera"), title: "상대방이 사진을 기다리고 있어요!", body: "지금 바로 사진을 보내볼까요?", time: "어제", isRead: true),
//        NotiItem(image: UIImage(named: "ic_heart"), title: "오늘의 랜덤 질문이 도착했어요!", body: "오늘의 질문에 답해볼까요?", time: "어제", isRead: true)
//    ]
    
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
         
        setLeftBarButton(image: UIImage(systemName: "chevron.left"))
    }
    
    private func checkNotificationPermissionAndUpdateUI() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                if settings.authorizationStatus == .authorized {
                    self.updateViewState(hasItems: !self.notiItems.isEmpty)
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
            tableView.configure(with: notiItems)
        }
    }
    
    private func showNoRequestView() {
        noRequestView.isHidden = false
        emptyView.isHidden = true
        tableView.isHidden = true
    }

}
