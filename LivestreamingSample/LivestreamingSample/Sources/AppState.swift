//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI

class AppState: ObservableObject {
    
    @Published var userState: UserState = .notLoggedIn
    @Published var deeplinkCallId: String?
    @Published var currentUser: User?
    
    var streamWrapper: StreamWrapper?
    
    static let shared = AppState()
    
    private init() {}
    
    func logout() {
        Task {
            await streamWrapper?.logout()
            UnsecureUserRepository.shared.removeCurrentUser()
            streamWrapper = nil
            userState = .notLoggedIn
        }
    }
}

enum UserState {
    case notLoggedIn
    case loggedIn
}
