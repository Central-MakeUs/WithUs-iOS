//
//  UserManager.swift
//  WithUs-iOS
//
//  Created by Hubriz iOS on 1/30/26.
//

import Foundation

final class UserManager {
    static let shared = UserManager()
    
    private let storage = UserDefaultsManager.shared
    
    private init() {}
    
    var nickName: String? {
        get {
            return storage.nickname
        }
        set {
            storage.nickname = newValue
        }
    }
    
    var userId: String? {
        get {
            return storage.userId
        }
        set {
            storage.userId = newValue
        }
    }
    
    var profileImageUrl: String? {
        get {
            return storage.profileImageUrl
        }
        set {
            storage.profileImageUrl = newValue
        }
    }
}
