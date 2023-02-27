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
        LogConfig.level = .debug
        setupStreamVideo(with: "w6yaq5388uym", userCredentials: .demoUserMartin)
    }
    
    private func setupStreamVideo(
        with apiKey: String,
        userCredentials: UserCredentials
    ) {
        streamVideo = StreamVideoUI(
            apiKey: apiKey,
            user: userCredentials.user,
            token: userCredentials.token,
            videoConfig: VideoConfig(),
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
    static let demoUserMartin = UserCredentials(
        user: User(
            id: "martin",
            name: "Martin",
            imageURL: URL(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/802d2/martin-mitrevski.webp")!,
            extraData: [:]
        ),
        token: try! UserToken(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwidXNlcl9pZCI6Im1hcnRpbiIsImlhdCI6MTUxNjIzOTAyMn0.Rgz8X6arOZduR03BuDFH-ji5yixtPrj5w7PKj1gNyMg"
        )
    )
    static let demoUserOliver = UserCredentials(
        user: User(
            id: "oliver.lazoroski@getstream.io",
            name: "Oliver",
            imageURL: URL(string: "https://getstream.io/static/b8a66e9095cf9c73316db18b8c1200b5/802d2/oliver-lazoroski.webp")!,
            extraData: [:]
        ),
        token: try! UserToken(rawValue: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwidXNlcl9pZCI6Im9saXZlci5sYXpvcm9za2lAZ2V0c3RyZWFtLmlvIiwiaWF0IjoxNTE2MjM5MDIyfQ.qDNb4I_zygaWL_qgHyjV0dg2IiSmvNpuuU86F8eFy1s"
        )
    )
}
