//
// Copyright © 2023 Stream.io Inc. All rights reserved.
//

import StreamVideo
import SwiftUI

class AppState: ObservableObject {
    
    @Published var userState: UserState = .notLoggedIn
    
    var currentUser: User?
    
    var streamVideo: StreamVideo?
 }

/* Login-related functionality */
extension AppState {
    func login(_ user: UserCredentials) {
        // save the selected user
        UnsecureUserRepository.shared.save(user: user)
        currentUser = user.userInfo
        
        // initialize StreamVideo
        let streamVideo = StreamVideo(
            apiKey: "us83cfwuhy8n",
            user: user.userInfo,
            token: user.token,
            videoConfig: VideoConfig(
                videoEnabled: false,
                persitingSocketConnection: true,
                joinVideoCallInstantly: true
            ),
            tokenProvider: { result in
                result(.success(user.token))
            }
        )
        self.streamVideo = streamVideo
        
        // change the login state
        userState = .loggedIn
    }
    
    func checkLoggedInUser() {
        if let user = UnsecureUserRepository.shared.loadCurrentUser() {
            login(user)
        }
    }
    
    func logout() {
        if let userToken = UnsecureUserRepository.shared.currentVoipPushToken(),
            let controller = streamVideo?.makeVoipNotificationsController() {
            controller.removeDevice(with: userToken)
        }
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
