//
//  KeychainManager.swift
//  RxGithub
//
//  Created by Alexandr Synelnyk on 13.07.2020.
//  Copyright © 2020 Alexandr. All rights reserved.
//

import Foundation
import KeychainSwift

class KeychainService {
    
    private static let keychain = KeychainSwift()
    
    enum Keys: String {
        case username = "accessUsername"
        case password = "accessPassword"
    }
    
    static var username: String {
        keychain.get(Keys.username.rawValue) ?? ""
    }
    
    static func set(username: String) {
        keychain.set(username, forKey: Keys.username.rawValue)
    }
    
    static var password: String {
        keychain.get(Keys.password.rawValue) ?? ""
    }
    
    static func set(password: String) {
        keychain.set(password, forKey: Keys.password.rawValue)
    }
    
    static func set(username: String, password: String) {
        set(username: username)
        set(password: password)
    }
    
    static func clear() {
        keychain.delete(Keys.username.rawValue)
        keychain.delete(Keys.password.rawValue)
    }
}
