//
//  LivestreamDemoAppApp.swift
//  LivestreamDemoApp
//
//  Created by Martin Mitrevski on 6.8.24.
//

import SwiftUI
import StreamVideo
import StreamChat

@main
struct LivestreamDemoApp: App {
    
    var body: some Scene {
        WindowGroup {
            UserSelectionView()
        }
    }
}
