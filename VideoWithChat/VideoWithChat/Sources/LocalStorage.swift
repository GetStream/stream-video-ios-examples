//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import Foundation
import StreamVideo

protocol UserRepository {
    
    func save(user: UserCredentials)
    
    func loadCurrentUser() -> UserCredentials?
    
    func removeCurrentUser()
    
    func save(token: String)
    
}

protocol VoipTokenHandler {
    
    func save(voipPushToken: String?)
    
    func currentVoipPushToken() -> String?
    
}

//NOTE: This is just for simplicity. User data shouldn't be kept in `UserDefaults`.
class UnsecureUserRepository: UserRepository, VoipTokenHandler {
    
    private let defaults = UserDefaults.standard
    private let userKey = "stream.video.user"
    private let tokenKey = "stream.video.token"
    private let chatTokenKey = "stream.chat.token"
    private let voipPushTokenKey = "stream.video.voip.token"
    
    static let shared = UnsecureUserRepository()
    
    private init() {}
    
    func save(user: UserCredentials) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user.user) {
            defaults.set(encoded, forKey: userKey)
            defaults.set(user.tokenValue, forKey: tokenKey)
        }
    }
    
    func save(token: String) {
        defaults.set(token, forKey: tokenKey)
    }
    
    func loadCurrentUser() -> UserCredentials? {
        if let savedUser = defaults.object(forKey: userKey) as? Data {
            let decoder = JSONDecoder()
            do {
                let loadedUser = try decoder.decode(User.self, from: savedUser)
                guard let tokenValue = defaults.value(forKey: tokenKey) as? String else {
                    throw ClientError.Unexpected()
                }
                return UserCredentials(user: loadedUser, tokenValue: tokenValue)
            } catch {
                log.error("Error while decoding user: \(String(describing: error))")
            }
        }
        return nil
    }
    
    func save(voipPushToken: String?) {
        defaults.set(voipPushToken, forKey: voipPushTokenKey)
    }
    
    func currentVoipPushToken() -> String? {
        defaults.value(forKey: voipPushTokenKey) as? String
    }
    
    func removeCurrentUser() {
        defaults.set(nil, forKey: userKey)
        defaults.set(nil, forKey: tokenKey)
        defaults.set(nil, forKey: voipPushTokenKey)
    }
    
    
}
