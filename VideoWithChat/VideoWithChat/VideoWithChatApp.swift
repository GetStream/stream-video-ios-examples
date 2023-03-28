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
    
    @StateObject var appState = AppState()
        
    init() {
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    StageView(appState: appState, callId: appState.deeplinkCallId)
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
