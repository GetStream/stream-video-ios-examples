//
//  VideoWithChatApp.swift
//  VideoWithChat
//
//  Created by Martin Mitrevski on 14.11.22.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

@main
struct VideoWithChatApp: App {
    private let userRepository: UserRepository = UnsecureUserRepository.shared
    
    @State var streamWrapper: StreamWrapper?
    
    @ObservedObject var appState = AppState.shared
        
    init() {
        checkLoggedInUser()
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    StageView(callId: appState.deeplinkCallId)
                } else {
                    LoginView() { user in
                        handleSelectedUser(user)
                    }
                }
            }
            .onOpenURL { url in
                handle(url: url)
            }
        }
    }
    
    private func handle(url: URL) {
        let queryParams = url.queryParameters
        let users = UserCredentials.builtInUsers
        guard let userId = queryParams["user_id"],
              let callId = queryParams["call_id"] else {
            return
        }
        let user = users.filter { $0.id == userId }.first
        if let user = user {
            appState.deeplinkCallId = callId
            appState.userState = .loggedIn
            handleSelectedUser(user, callId: callId)
        }
    }
    
    private func handleSelectedUser(_ user: UserCredentials, callId: String? = nil) {
        streamWrapper = StreamWrapper(
            apiKey: "us83cfwuhy8n",
            userCredentials: user,
            videoFilters: FiltersService.supportedFilters,
            tokenProvider: { result in
                //TODO: Provide token here.
                result(.success(user.tokenValue))
            }
        )
        appState.streamWrapper = streamWrapper
    }
    
    private func checkLoggedInUser() {
        if let user = userRepository.loadCurrentUser() {
            appState.currentUser = user.user
            appState.userState = .loggedIn
            handleSelectedUser(user)
        }
    }
}
