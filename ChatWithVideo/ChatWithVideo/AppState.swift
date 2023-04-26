//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI

@MainActor
class AppState: ObservableObject {
    
    let userRepository: UserRepository = UnsecureUserRepository.shared
    
    @Published var userState: UserState = .notLoggedIn
    @Published var deeplinkCallId: String?
    @Published var currentUser: User?
    
    var streamWrapper: StreamWrapper?
    
    static let shared = AppState()
    
    private init() {}
    
    func logout() {
        Task {
            await streamWrapper?.logout()
            userRepository.removeCurrentUser()
            streamWrapper = nil
            currentUser = nil
            userState = .notLoggedIn
        }
    }
}

enum UserState {
    case notLoggedIn
    case loggedIn
}
