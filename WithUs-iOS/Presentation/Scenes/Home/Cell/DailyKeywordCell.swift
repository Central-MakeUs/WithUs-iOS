//
//  DailyKeywordCell.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/30/26.
//

import Foundation
import UIKit
import SnapKit
import Then

class DailyKeywordCell: UICollectionViewCell {
    var onSendPhotoTapped: (() -> Void)?
    var onNotifyTapped: (() -> Void)?
    
    private lazy var allViews: [UIView] = [
        waitingBothView,
        keywordMyOnlyView,
        keywordPartnerOnlyView,
        keywordBothView
    ]
    
    private let waitingBothView = WaitingBothView()
    private let keywordMyOnlyView = KeywordMyOnlyView()
    private let keywordPartnerOnlyView = KeywordPartnerOnlyView()
    private let keywordBothView = KeywordBothAnsweredView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        allViews.forEach {
            contentView.addSubview($0)
            $0.snp.makeConstraints { $0.edges.equalToSuperview() }
            $0.isHidden = true
        }
        setupCallbacks()
    }
    
    private func setupCallbacks() {
        waitingBothView.onSendPhotoTapped = { [weak self] in
            self?.onSendPhotoTapped?()
        }
        
        keywordPartnerOnlyView.onSendPhotoTapped = { [weak self] in
            self?.onSendPhotoTapped?()
        }
        
        keywordMyOnlyView.onNotifyTapped = { [weak self] in
            self?.onNotifyTapped?()
        }
    }
    
    func configure(with data: TodayKeywordResponse) {
        reset()
        
        let myAnswered = data.myInfo?.questionImageUrl != nil
        let partnerAnswered = data.partnerInfo?.questionImageUrl != nil
        
        switch (myAnswered, partnerAnswered) {
        case (false, false):
            show(view: waitingBothView)
            waitingBothView.configure(question: data.question)
            
        case (false, true):
            show(view: keywordPartnerOnlyView)
//            keywordPartnerOnlyView.configure(
//                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
//                partnerName: data.partnerInfo?.name ?? "",
//                partnerTime: data.partnerInfo?.answeredAt ?? "",
//                partnerCaption: data.question,
//                myName: data.myInfo?.name ?? ""
//            )
            
        case (true, false):
            show(view: keywordMyOnlyView)
            keywordMyOnlyView.configure(
                myImageURL: data.myInfo?.questionImageUrl ?? "",
                myName: data.myInfo?.name ?? "",
                myTime: data.myInfo?.answeredAt ?? "",
                myProfileURL: data.myInfo?.profileImageUrl ?? ""
            )
            
        case (true, true):
            show(view: keywordBothView)
//            keywordBothView.configure(
//                myImageURL: data.myInfo?.questionImageUrl ?? "",
//                myName: data.myInfo?.name ?? "",
//                myTime: data.myInfo?.answeredAt ?? "",
//                myCaption: data.question,
//                partnerImageURL: data.partnerInfo?.questionImageUrl ?? "",
//                partnerName: data.partnerInfo?.name ?? "",
//                partnerTime: data.partnerInfo?.answeredAt ?? "",
//                partnerCaption: data.question
//            )
        }
    }
    
    private func show(view: UIView) {
        view.isHidden = false
    }
    
    func reset() {
        allViews.forEach { $0.isHidden = true }
    }
}

