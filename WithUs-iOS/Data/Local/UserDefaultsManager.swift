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
        static let fullName = "fullName"
        static let userId = "userId"
        static let profileImageUrl = "profileImageUrl"
        
        static let appleUserIdentifier = "appleUserIdentifier"
        static let email = "email"
        
        static let shouldShowLogin = "shouldShowLogin"
        static let shouldShowOnboarding = "shouldShowOnboarding"
    }
    
    var fullName: String? {
        get {
            return userDefaults.string(forKey: Keys.fullName)
        }
        set {
            if let nickname = newValue {
                userDefaults.set(nickname, forKey: Keys.fullName)
            } else {
                userDefaults.removeObject(forKey: Keys.fullName)
            }
        }
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
    
    var appleUserIdentifier: String? {
        get {
            userDefaults.string(forKey: Keys.appleUserIdentifier)
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.appleUserIdentifier)
            } else {
                userDefaults.removeObject(forKey: Keys.appleUserIdentifier)
            }
        }
    }
    
    var email: String? {
        get {
            userDefaults.string(forKey: Keys.email)
        }
        set {
            if let value = newValue {
                userDefaults.set(value, forKey: Keys.email)
            } else {
                userDefaults.removeObject(forKey: Keys.email)
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
    
    var shouldShowLogin: Bool {
        get {
            return userDefaults.bool(forKey: Keys.shouldShowLogin)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.shouldShowLogin)
        }
    }
    
    var shouldShowOnboarding: Bool {
        get {
            return userDefaults.bool(forKey: Keys.shouldShowOnboarding)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.shouldShowOnboarding)
        }
    }
    
    func clearAllDataForLogout() {
        shouldShowLogin = true
        shouldShowOnboarding = false
        accessToken = nil
        refreshToken = nil
        nickname = nil
        fullName = nil
        userId = nil
        profileImageUrl = nil
        appleUserIdentifier = nil
        email = nil
        URLCache.shared.removeAllCachedResponses()
        
        HTTPCookieStorage.shared.cookies?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
        
        userDefaults.synchronize()
    }
    
    func clearAllDataForWithdrawal() {
        shouldShowLogin = false
        shouldShowOnboarding = true
        accessToken = nil
        refreshToken = nil
        nickname = nil
        fullName = nil
        userId = nil
        profileImageUrl = nil
        appleUserIdentifier = nil
        email = nil
        
        URLCache.shared.removeAllCachedResponses()
        HTTPCookieStorage.shared.cookies?.forEach {
            HTTPCookieStorage.shared.deleteCookie($0)
        }
        
        userDefaults.synchronize()
    }
}
