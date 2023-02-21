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
    
    init() {
        LogConfig.level = .debug
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
