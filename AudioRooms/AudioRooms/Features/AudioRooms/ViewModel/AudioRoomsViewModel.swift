//
//  AudioRoomsViewModel.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 27.1.23.
//

import SwiftUI
import StreamVideo
import Combine

@MainActor
class AudioRoomsViewModel: ObservableObject {
    
    @Published var audioRooms = [AudioRoom]()
    @Published var selectedAudioRoom: AudioRoom?
    
    @Injected(\.streamVideo) var streamVideo
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        Task {
            let callsQuery = CallsQuery(sortParams: [], filters: ["audioRoomCall": .bool(true)], watch: true)
            let controller = streamVideo.makeCallsController(callsQuery: callsQuery)
            controller.$calls
                .sink { retrievedAudioRooms in
                    DispatchQueue.main.async {
                        self.audioRooms = retrievedAudioRooms.compactMap { callData in
                            return AudioRoom(from: callData.customData, id: callData.callCid)
                        }
                    }
                }
                .store(in: &cancellables)
            try? await controller.loadNextCalls()
        }
    }
    
    deinit {
        self.cancellables.removeAll()
    }
}

