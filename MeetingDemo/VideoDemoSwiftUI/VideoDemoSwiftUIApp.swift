//
//  VideoDemoSwiftUIApp.swift
//  VideoDemoSwiftUI
//
//  Created by Martin Mitrevski on 17.1.23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

@main
struct VideoDemoSwiftUIApp: App {
    
    @State var streamVideo: StreamVideoUI?
    
    init() {
        setupStreamVideo(with: "us83cfwuhy8n", userCredentials: .demoUser)
    }
    
    private func setupStreamVideo(
        with apiKey: String,
        userCredentials: UserCredentials
    ) {
        streamVideo = StreamVideoUI(
            apiKey: apiKey,
            user: userCredentials.user,
            token: userCredentials.token,
            videoConfig: VideoConfig(joinVideoCallInstantly: true),
            tokenProvider: { result in
                // Call your networking service to generate a new token here.
                // When finished, call the result handler with either .success or .failure.
                result(.success(userCredentials.token))
            }
        )
    }
    
    var body: some Scene {
        WindowGroup {
            MeetingsView()
        }
    }
}

struct UserCredentials {
    let user: User
    let token: UserToken
}

extension UserCredentials {
    static let demoUser = UserCredentials(
        user: User(
            id: "martin",
            name: "Martin",
            imageURL: URL(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp")!,
            extraData: [:]
        ),
        token: try! UserToken(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdHJlYW0tdmlkZW8tZ29AdjAuMS4wIiwic3ViIjoidXNlci9tYXJ0aW4iLCJpYXQiOjE2NzAxODg5ODQsInVzZXJfaWQiOiJtYXJ0aW4ifQ.aG3P_YqukrQZi50kkQqoc_GrzY38jnFVjYWDGbzrwDQ"
        )
    )
}
