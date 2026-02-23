//
//  InviteActivityItemSource.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/23/26.
//

import Foundation
import LinkPresentation

final class InviteActivityItemSource: NSObject, UIActivityItemSource {
    let inviteURL: String
    
    init(inviteURL: String) {
        self.inviteURL = inviteURL
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
                                  itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return inviteURL
    }
    
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = "상대방이 커플 연결을 기다리고 있어요!"
        metadata.originalURL = URL(string: inviteURL)
        
        if let image = UIImage(named: "login") {
            metadata.iconProvider = NSItemProvider(object: image)
        }
        
        return metadata
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return inviteURL
    }
}
