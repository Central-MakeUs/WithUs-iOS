//
//  UserDefaultsManager.swift
//  WithUs-iOS
//
//  Created by 지상률 on 1/14/26.
//

import Foundation

final class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let fcmToken = "fcmToken"
        static let nickname = "nickname"
        static let userId = "userId"
        static let profileImageUrl = "profileImageUrl"
    
    }
    
    var nickname: String? {
        get {
            return userDefaults.string(forKey: Keys.nickname)
        }
        set {
            if let nickname = newValue {
                userDefaults.set(nickname, forKey: Keys.nickname)
            } else {
                userDefaults.removeObject(forKey: Keys.nickname)
            }
        }
    }
    
    var userId: String? {
        get {
            return userDefaults.string(forKey: Keys.userId)
        }
        set {
            if let userId = newValue {
                userDefaults.set(userId, forKey: Keys.userId)
            } else {
                userDefaults.removeObject(forKey: Keys.userId)
            }
        }
    }
    
    var profileImageUrl: String? {
        get {
            return userDefaults.string(forKey: Keys.profileImageUrl)
        }
        set {
            if let url = newValue {
                userDefaults.set(url, forKey: Keys.profileImageUrl)
            } else {
                userDefaults.removeObject(forKey: Keys.profileImageUrl)
            }
        }
    }
    
    var accessToken: String? {
        get {
            return userDefaults.string(forKey: Keys.accessToken)
        }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: Keys.accessToken)
            } else {
                userDefaults.removeObject(forKey: Keys.accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get {
            return userDefaults.string(forKey: Keys.refreshToken)
        }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: Keys.refreshToken)
            } else {
                userDefaults.removeObject(forKey: Keys.refreshToken)
            }
        }
    }
    
    var fcmToken: String? {
        get {
            return userDefaults.string(forKey: Keys.fcmToken)
        }
        set {
            if let token = newValue {
                userDefaults.set(token, forKey: Keys.fcmToken)
            } else {
                userDefaults.removeObject(forKey: Keys.fcmToken)
            }
        }
    }
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
    
    func clearFCMToken() {
        fcmToken = nil
    }
}
