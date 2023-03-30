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
    
    @StateObject var appState = AppState()
        
    init() {
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    let chatViewFactory = ChatViewFactory(appState: appState)
                    ChatChannelListView(viewFactory: chatViewFactory)
                        .modifier(CallModifier(viewModel: chatViewFactory.callViewModel))
                } else {
                    LoginView(appState: appState)
                }
            }
            .onAppear {
                appState.checkLoggedInUser()
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
            Task {
                try await appState.login(user)
            }
        }
    }

}
