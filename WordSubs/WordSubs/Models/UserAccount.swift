//
//  UserAccount.swift
//  WordSubs
//
//  Created by Ramit Sharma on 20/11/24.
//

import Foundation

struct UserAccount: Codable {
    let email: String
    let name: String
    var bookmarks: Set<UUID>
    
    static func save(_ account: UserAccount) {
        if let encoded = try? JSONEncoder().encode(account) {
            UserDefaults.standard.set(encoded, forKey: "userAccount")
        }
    }
    
    static func load() -> UserAccount? {
        guard let data = UserDefaults.standard.data(forKey: "userAccount"),
              let account = try? JSONDecoder().decode(UserAccount.self, from: data)
        else { return nil }
        return account
    }
} 