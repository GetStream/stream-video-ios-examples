//
//  UserCredentials.swift
//  ChatWithVideoUIKit
//
//  Created by Martin Mitrevski on 22.11.22.
//

import Foundation
import StreamVideo

struct UserCredentials: Identifiable, Codable {
    var id: String {
        user.id
    }
    let user: User
    let videoTokenValue: String
    let chatTokenValue: String
}

extension UserCredentials {
    var videoToken: UserToken {
        try! UserToken(rawValue: videoTokenValue)
    }
}
