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
        get { storage.nickname }
        set { storage.nickname = newValue }
    }

    var userId: String? {
        get { storage.userId }
        set { storage.userId = newValue }
    }

    var profileImageUrl: String? {
        get { storage.profileImageUrl }
        set { storage.profileImageUrl = newValue }
    }

    // Apple
    var appleUserIdentifier: String? {
        get { storage.appleUserIdentifier }
        set { storage.appleUserIdentifier = newValue }
    }

    var email: String? {
        get { storage.email }
        set { storage.email = newValue }
    }
}

