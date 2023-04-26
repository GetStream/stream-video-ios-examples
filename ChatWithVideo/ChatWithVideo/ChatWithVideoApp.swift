//
//  ChatWithVideoApp.swift
//  ChatWithVideo
//
//  Created by Martin Mitrevski on 15.11.22.
//

import SwiftUI
import struct StreamChatSwiftUI.ChatChannelListView
import StreamVideo
import StreamVideoSwiftUI

@main
struct ChatWithVideoApp: App {
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
                    ChatChannelListView(viewFactory: ChatViewFactory.shared)
                        .modifier(CallModifier(viewModel: ChatViewFactory.shared.callViewModel))
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
        let users = User.builtInUsers
        guard let userId = queryParams["user_id"],
              let callId = queryParams["call_id"] else {
            return
        }
        let user = users.filter { $0.id == userId }.first
        if let user = user {
            appState.deeplinkCallId = callId
            appState.userState = .loggedIn
            Task {
                let token = try await TokenService.shared.fetchToken(for: user.id)
                let credentials = UserCredentials(user: user, tokenValue: token.rawValue)
                handleSelectedUser(credentials, callId: callId)
            }
        }
    }
    
    private func handleSelectedUser(_ user: UserCredentials, callId: String? = nil) {
        streamWrapper = StreamWrapper(
            apiKey: "hd8szvscpxvd",
            userCredentials: user,
            tokenProvider: { result in
                Task {
                    do {
                        let token = try await TokenService.shared.fetchToken(for: user.id)
                        userRepository.save(token: token.rawValue)
                        result(.success(token.rawValue))
                    } catch {
                        result(.failure(error))
                    }
                }
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
