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
    private var controller: CallsController?
    
    init() {
        let callsQuery = CallsQuery(sortParams: [], filters: ["audioRoomCall": .bool(true)], watch: true)
        self.controller = streamVideo.makeCallsController(callsQuery: callsQuery)
        controller?.$calls
            .sink { retrievedAudioRooms in
                print("[ARVM] Retrieved \(retrievedAudioRooms.count) rooms.")
                DispatchQueue.main.async {
                    self.audioRooms = retrievedAudioRooms.compactMap { callData in
                        if let _ = callData.endedAt { return nil }
                        return AudioRoom(from: callData.customData, id: callData.callCid)
                    }
                    
                    print("[ARVM] Casted \(self.audioRooms.count) rooms.")
                }
            }
            .store(in: &cancellables)
    }
    
    func loadRooms() {
        Task {
            try? await controller?.loadNextCalls()
        }
    }
    
    deinit {
        self.cancellables.removeAll()
    }
}

