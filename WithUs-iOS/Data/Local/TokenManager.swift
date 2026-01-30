//
//  TokenManager.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/13/26.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    
    private let storage = UserDefaultsManager.shared
    
    private init() {}
    
    var accessToken: String? {
        get {
            return storage.accessToken
        }
        set {
            storage.accessToken = newValue
        }
    }
    
    var refreshToken: String? {
        get {
            return storage.refreshToken
        }
        set {
            storage.refreshToken = newValue
        }
    }
    
    func clearTokens() {
        storage.clearTokens()
    }
}
