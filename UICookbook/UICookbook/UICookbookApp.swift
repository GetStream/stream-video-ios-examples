//
//  UICookbookApp.swift
//  UICookbook
//
//  Created by Martin Mitrevski on 13.3.23.
//

import SwiftUI
import StreamVideo

@main
struct UICookbookApp: App {
    @StateObject var appState = AppState()
    
    init() {
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    HomeView(appState: appState)
                } else {
                    LoginView(appState: appState)
                }
            }
            .onAppear {
                appState.checkLoggedInUser()
            }
        }
    }
}
