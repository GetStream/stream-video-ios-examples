//
//  CreateRoomViewModel.swift
//  AudioRooms
//
//  Created by Stefan Blos on 28.04.23.
//

import Foundation
import StreamVideo

class CreateRoomViewModel: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    func createRoom(title: String, description: String) {
        Task {
            let call = streamVideo.call(callType: "audio_room", callId: UUID().uuidString)
            let data = try await call.getOrCreate(
                members: [user.asAdmin.member],
                customData: [
                    "title": .string(title),
                    "description": .string(description),
                    "hosts": .array([
                        .dictionary(user.toDict())
                    ]),
                    "audioRoomCall": .bool(true)
                ],
                ring: false
            )
            print("Audio room created at \(data.createdAt)")
        }
    }
    
}
