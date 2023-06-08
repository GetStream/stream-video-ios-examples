//
//  AudioRoomsApp.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//e

import SwiftUI
import StreamVideo

@main
struct AudioRoomsApp: App {
    
    @StateObject var appState = AppState()
    
    init() {
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if appState.userState == .loggedIn {
                    AudioRoomsView(appState: appState)
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
