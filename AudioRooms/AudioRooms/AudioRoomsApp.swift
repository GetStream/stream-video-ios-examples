//
//  AudioRoomsApp.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import SwiftUI
import StreamVideo

@main
struct AudioRoomsApp: App {
    
    private let userRepository: UserRepository = UnsecureUserRepository.shared
    
    @State var streamVideo: StreamVideo?
    
    @ObservedObject var appState = AppState.shared
    
    init() {
        checkLoggedInUser()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    AudioRoomsView()
                } else {
                    LoginView() { user in
                        handleSelectedUser(user)
                    }
                }
            }
        }
    }
    
    private func handleSelectedUser(_ user: UserCredentials, callId: String? = nil) {
        let streamVideo = StreamVideo(
            apiKey: "us83cfwuhy8n",
            user: user.userInfo,
            token: user.token,
            videoConfig: VideoConfig(
                persitingSocketConnection: true,
                joinVideoCallInstantly: true
            ),
            tokenProvider: { result in
                result(.success(user.token))
            }
        )
        appState.streamVideo = streamVideo
    }
    
    private func checkLoggedInUser() {
        if let user = userRepository.loadCurrentUser() {
            appState.currentUser = user.userInfo
            appState.userState = .loggedIn
            handleSelectedUser(user)
        }
    }
}
