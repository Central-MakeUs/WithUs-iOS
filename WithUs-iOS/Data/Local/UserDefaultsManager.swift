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
