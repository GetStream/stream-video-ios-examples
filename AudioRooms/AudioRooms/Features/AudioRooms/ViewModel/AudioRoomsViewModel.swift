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
    
    @Published var liveAudioRooms = [AudioRoom]()
    @Published var upcomingAudioRooms = [AudioRoom]()
    @Published var endedAudioRooms = [AudioRoom]()
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
            .sink { [weak self] audioRooms in
                var newLiveAudioRooms: [AudioRoom] = []
                var newUpcomingAudioRooms: [AudioRoom] = []
                var newEndedAudioRooms: [AudioRoom] = []
                audioRooms.forEach { audioRoom in
                    switch audioRoom.type {
                    case .live:
                        newLiveAudioRooms.append(audioRoom)
                    case .upcoming:
                        newUpcomingAudioRooms.append(audioRoom)
                    case .ended:
                        newEndedAudioRooms.append(audioRoom)
                    }
                }

                self?.liveAudioRooms = newLiveAudioRooms
                self?.upcomingAudioRooms = newUpcomingAudioRooms
                self?.endedAudioRooms = newEndedAudioRooms
            }
            .store(in: &cancellables)
    }

    deinit { self.cancellables.forEach { $0.cancel() } }

    func loadRooms() {
        Task { try? await controller?.loadNextCalls() }
    }
}

extension AudioRoom {

    fileprivate init?(_ response: CallStateResponseFields) {
        let callData = response.call
        let dict = callData.custom
        guard
            let title = dict["title"]?.stringValue,
            let hosts = dict["hosts"]?.arrayValue?.compactMap(\.dictionaryValue).compactMap(User.init)
        else {
            return nil
        }
        self = .init(
            id: callData.cid,
            title: title,
            subtitle: dict["description"]?.stringValue ?? "",
            hosts: hosts,
            type: {
                if callData.backstage == false {
                    return .live
                } else if callData.endedAt == nil {
                    return .upcoming
                } else {
                    return .ended
                }
            }()
        )
    }
}
