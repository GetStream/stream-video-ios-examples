//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    
    let tokenService = TokenService.shared
    
    @Published var userState: UserState = .notLoggedIn
    
    var currentUser: User?
    
    var streamVideo: StreamVideo?

    private var connectionStatusCancellable: AnyCancellable?
 }

/* Login-related functionality */
extension AppState {
    func login(_ user: User) async throws {
        let token = try await self.tokenService.fetchToken(for: user.id)
        let credentials = UserCredentials(userInfo: user, token: token)
        // save the selected user
        UnsecureUserRepository.shared.save(user: credentials)
        currentUser = user
        
        // initialize StreamVideo
        let streamVideo = StreamVideo(
            apiKey: Config.apiKey,
            user: user,
            token: token,
            videoConfig: VideoConfig(),
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
