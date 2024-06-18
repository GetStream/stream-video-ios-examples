//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    
    @Published var userState: UserState = .notLoggedIn

    var currentUser: User?
    
    var streamVideo: StreamVideo?

    private var connectionStatusCancellable: AnyCancellable?
 }

/* Login-related functionality */
extension AppState {
    func login(_ user: User) async throws {
        let (apiKey, token) = try await AuthenticationProvider.fetchToken(for: user.id)
        let credentials = UserCredentials(userInfo: user, token: token)
        // save the selected user
        UnsecureUserRepository.shared.save(user: credentials)
        currentUser = user
        
        // initialize StreamVideo
        let streamVideo = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: token,
            videoConfig: VideoConfig(),
            tokenProvider: { result in
                Task {
                    do {
                        let (_, token) = try await AuthenticationProvider.fetchToken(for: user.id)
                        result(.success(token))
                    } catch {
                        result(.failure(error))
                    }
                }
            }
        )
        self.streamVideo = streamVideo

        connectionStatusCancellable?.cancel()
        connectionStatusCancellable = streamVideo
            .state
            .$connection
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.userState = $0 == .connected ? .loggedIn : .notLoggedIn }
    }
    
    func checkLoggedInUser() {
        if let user = UnsecureUserRepository.shared.loadCurrentUser() {
            Task {
                try await login(user.userInfo)
            }
        }
    }
    
    func logout() {
        UnsecureUserRepository.shared.removeCurrentUser()
        Task {
            await streamVideo?.disconnect()
            streamVideo = nil
            
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
