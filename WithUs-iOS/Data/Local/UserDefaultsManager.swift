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
    
    // MARK: - Keys
    
    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
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
    
    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}
