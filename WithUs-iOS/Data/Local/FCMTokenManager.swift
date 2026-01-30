//
//  FCMTokenManager.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/20/26.
//

import Foundation

final class FCMTokenManager {
    static let shared = FCMTokenManager()
    
    private let storage = UserDefaultsManager.shared
    
    private init() {}
    
    var fcmToken: String? {
        get {
            return storage.fcmToken
        }
        set {
            storage.fcmToken = newValue
        }
    }
    
    func clearTokens() {
        storage.clearFCMToken()
    }
}
