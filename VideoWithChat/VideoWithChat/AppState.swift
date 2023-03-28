//
// Copyright © 2022 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI

@MainActor
class AppState: ObservableObject {
    
    let tokenService = TokenService.shared

    // Login-related
    @Published var userState: UserState = .notLoggedIn
    @Published var currentUser: User?
    
    // Deep Links
    @Published var deeplinkCallId: String?
    
    // Controlling Calls
    @Published var activeCallController: CallController?
    
    var streamWrapper: StreamWrapper?
}

/* Login-related functionality */
extension AppState {
    
    func login(_ user: User) async throws {
        let token = try await self.tokenService.fetchToken(for: user.id)
        let credentials = UserCredentials(user: user, tokenValue: token.rawValue)
        // save the selected user
        UnsecureUserRepository.shared.save(user: credentials)
        currentUser = user
        
        // initialize StreamWrapper
        let streamWrapper = StreamWrapper(
            apiKey: Config.apiKey,
            user: user,
            initialToken: token,
            tokenProvider: { result in
                Task {
                    do {
                        let token = try await TokenService.shared.fetchToken(for: user.id)
                        result(.success(token))
                    } catch {
                        result(.failure(error))
                    }
                }
            }
        )
        
        self.streamWrapper = streamWrapper
        
        // change the login state
        userState = .loggedIn
    }
    
    func checkLoggedInUser() {
        if let user = UnsecureUserRepository.shared.loadCurrentUser() {
            Task {
                try await login(user.user)
            }
        }
    }
    
    func logout() {
        if let userToken = UnsecureUserRepository.shared.currentVoipPushToken(),
           let controller = streamWrapper?.streamVideo.makeVoipNotificationsController() {
            controller.removeDevice(with: userToken)
        }
        UnsecureUserRepository.shared.removeCurrentUser()
        Task {
            await streamWrapper?.streamVideo.disconnect()
            streamWrapper?.chatClient.disconnect()
            
            withAnimation {
                userState = .notLoggedIn
            }
        }
    }
}

enum UserState {
    case notLoggedIn
    case loggedIn
}
