//
//  ContentView.swift
//  AudioRooms
//
//  Created by Ilias Pavlidakis on 1/8/23.
//

import SwiftUI
import StreamVideo
import StreamVideoSwiftUI

struct ContentView: View {
    @State var call: Call
    @ObservedObject var state: CallState
    @State private var callCreated: Bool = false
    
    private var client: StreamVideo
    private let apiKey: String = "" // The API key can be found in the Credentials section
    private let userId: String = "" // The User Id can be found in the Credentials section
    private let token: String = "" // The Token can be found in the Credentials section
    private let callId: String = "" // The CallId can be found in the Credentials section
    
    init() {
        let user = User(
            id: userId,
            name: "Martin", // name and imageURL are used in the UI
            imageURL: .init(string: "https://getstream.io/static/2796a305dd07651fcceb4721a94f4505/a3911/martin-mitrevski.webp")
        )
        
        // Initialize Stream Video client
        self.client = StreamVideo(
            apiKey: apiKey,
            user: user,
            token: .init(stringLiteral: token)
        )
        
        // Initialize the call object
        let call = client.call(callType: "audio_room", callId: callId)
        
        self.call = call
        self.state = call.state
    }
    
    var body: some View {
        VStack {
            if callCreated {
                DescriptionView(
                    title: call.state.custom["title"]?.stringValue,
                    description: call.state.custom["description"]?.stringValue,
                    participants: call.state.participants
                )
                Text("Speakers")
                Divider()
                ParticipantsView(
                    participants: call.state.participants.filter {$0.hasAudio}
                )
                Text("Listeners")
                Divider()
                ParticipantsView(
                    participants: call.state.participants.filter {!$0.hasAudio}
                )
                Spacer()
                PermissionRequestsView(call: call, state: state)
                ControlsView(call: call, state: state)
            } else {
                Text("loading...")
            }
        }.task {
            Task {
                guard !callCreated else { return }
                try await call.join(
                    create: true,
                    options: .init(
                        members: [
                            .init(userId: "john_smith"),
                            .init(userId: "jane_doe"),
                        ],
                        custom: [
                            "title": .string("SwiftUI heads"),
                            "description": .string("Talking about SwiftUI")
                        ]
                    )
                )
                try await call.sendReaction(type: "raise-hand", custom: ["mycustomfield": "hello"], emojiCode: ":smile:")
                callCreated = true
            }
        }
    }
}
