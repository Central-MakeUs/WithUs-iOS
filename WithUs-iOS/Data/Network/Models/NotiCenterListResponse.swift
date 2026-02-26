//
//  NotiCenterListResponse.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/26/26.
//

import Foundation
import UIKit

struct NotiCenterListResponse: Decodable {
    let notifications: [NotiCenterItem]
    let hasNext: Bool
    let nextCursor: String?
}

struct NotiCenterItem: Decodable {
    let title: String
    let content: String
    let push: String?
}

extension NotiCenterItem {
    var deepLink: DeepLink? {
        guard let push = push,
              let url = URL(string: "https://withus.p-e.kr\(push)") else { return nil }
        return DeepLink.from(url: url)
    }
    
    func toNotiItem() -> NotiItem {
        let image: UIImage?
        
        switch deepLink {
        case .invite:
            image = UIImage(named: "poke")
        case .todayQuestion:
            image = UIImage(named: "today_question")
        case .todayKeyword:
            image = UIImage(named: "today_daily")
        case .poke:
            image = UIImage(named: "poke")
        case nil:
            image = UIImage(named: "poke")
        }
        
        return NotiItem(
            image: image,
            title: title,
            body: content,
            time: "",
            isRead: true
        )
    }
}
