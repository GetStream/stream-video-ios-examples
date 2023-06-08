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
        let controller = streamVideo.makeCallsController(callsQuery: callsQuery)
        self.controller = controller
        controller
            .$calls
            .map { $0.compactMap(AudioRoom.init) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.audioRooms = $0 }
            .store(in: &cancellables)
    }

    deinit { self.cancellables.forEach { $0.cancel() } }

    func loadRooms() {
        Task { try? await controller?.loadNextCalls() }
    }
}

extension AudioRoom {

    fileprivate init?(_ callData: CallData) {
        guard
            callData.endedAt == nil,
            let model = AudioRoom(from: callData.customData, id: callData.callCid)
        else {
            return nil
        }
        self = model
    }
}
