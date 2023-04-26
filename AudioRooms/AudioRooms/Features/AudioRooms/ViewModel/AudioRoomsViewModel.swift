//
//  AudioRoomsViewModel.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import SwiftUI
import StreamVideo

@MainActor
class AudioRoomsViewModel: ObservableObject {

    @Published var audioRooms = [AudioRoom]()
    @Published var selectedAudioRoom: AudioRoom?
    
    @Injected(\.streamVideo) var streamVideo

    init() {
        Task {
            do {
                let callsQuery = CallsQuery(sortParams: [], filters: ["audioRoomCall": .bool(true)], watch: false)
                let controller = streamVideo.makeCallsController(callsQuery: callsQuery)
                try await controller.loadNextCalls()
                let retrievedAudioRooms = controller.calls.compactMap { callData in
                    print("Call: \(callData.extraData)")
                    return AudioRoom(from: callData.extraData, id: callData.callCid)
                }
                    
                self.audioRooms = retrievedAudioRooms
            } catch {
                print("We got an error: \(error.localizedDescription)")
            }
        }
    }
}

