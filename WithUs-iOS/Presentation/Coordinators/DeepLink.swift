//
//  DeepLink.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 2/13/26.
//

import Foundation

enum DeepLink {
    case invite(code: String?)
    case todayQuestion
    case todayKeyword(coupleKeywordId: String)
    
    static func from(url: URL) -> DeepLink? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return nil }
        
        let path = components.path
        
        switch path {
        case "/invite":
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
            return .invite(code: code)
            
        case "/today_question":
            return .todayQuestion
            
        default:
            if path.hasPrefix("/today_keyword/") {
                let id = path.replacingOccurrences(of: "/today_keyword/", with: "")
                return .todayKeyword(coupleKeywordId: id)
            }
            return nil
        }
    }
}

final class DeepLinkHandler {
    static let shared = DeepLinkHandler()
    
    private(set) var pendingDeepLink: DeepLink?
    
    private init() {}
    
    // 존재 여부만 확인 (꺼내지 않음)
    var hasPendingInviteCode: Bool {
        guard case .invite = pendingDeepLink else { return false }
        return true
    }
    
    func handle(url: URL) {
        guard let deepLink = DeepLink.from(url: url) else { return }
        pendingDeepLink = deepLink
    }
    
    func handle(deepLink: DeepLink) {
        pendingDeepLink = deepLink
    }
    
    func popPendingDeepLink() -> DeepLink? {
        defer { pendingDeepLink = nil }
        return pendingDeepLink
    }
    
    func popPendingInviteCode() -> String? {
        guard case .invite(let code) = pendingDeepLink else { return nil }
        pendingDeepLink = nil
        return code
    }
}
