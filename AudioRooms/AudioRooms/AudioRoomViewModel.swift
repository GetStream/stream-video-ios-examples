//
//  AudioRoomViewModel.swift
//  AudioRooms
//
//  Created by Martin Mitrevski on 30.1.23.
//

import Combine
import SwiftUI
import StreamVideo

@MainActor
class AudioRoomViewModel: ObservableObject {
    
    @Injected(\.streamVideo) var streamVideo
    
    @Published var callViewModel = CallViewModel()
    
    @Published var hosts = [CallParticipant]()
    @Published var otherUsers = [CallParticipant]()
    //TODO: only temporary until permissions done.
    @Published var hasPermissionsToSpeak = false
    @Published var isUserMuted = true
    @Published var loading = true
    
    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    
    init(audioRoom: AudioRoom) {
        self.audioRoom = audioRoom
        checkAudioSettings()
        callViewModel.joinCall(callId: audioRoom.id)
        subscribeForParticipantChanges()
        subscribeForAudioChanges()
        subscribeForCallStateChanges()
    }
    
    func leaveCall() {
        callViewModel.hangUp()
    }
    
    func changeMuteState() {
        callViewModel.toggleMicrophoneEnabled()
    }
    
    func raiseHand() {
        //TODO: implement when permissions are ready.
    }
    
    private func checkAudioSettings() {
        // Only temporary, until permissions are implemented.
        let hostIds = self.audioRoom.hosts.map { $0.id }
        let isCurrentUserHost = hostIds.contains(streamVideo.user.id)
        hasPermissionsToSpeak = isCurrentUserHost
        isUserMuted = !isCurrentUserHost
        callViewModel.callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
    }
    
    private func subscribeForParticipantChanges() {
        callViewModel.$callParticipants.sink { [weak self] participants in
            guard let self = self else { return }
            let hostIds = self.audioRoom.hosts.map { $0.id }
            self.hosts = participants.filter { (key, participant) in
                hostIds.contains(participant.userId)
            }
            .map { $0.value }
            .sorted(by: { $0.name < $1.name })
            
            self.otherUsers = participants.filter { (key, participant) in
                !hostIds.contains(participant.userId)
            }
            .map { $0.value }
            .sorted(by: { $0.name < $1.name })
        }
        .store(in: &cancellables)
    }
    
    private func subscribeForAudioChanges() {
        callViewModel.$callSettings.sink { [weak self] callSettings in
            guard let self = self else { return }
            self.isUserMuted = !callSettings.audioOn
        }
        .store(in: &cancellables)
    }
    
    private func subscribeForCallStateChanges() {
        callViewModel.$callingState.sink { [weak self] callState in
            guard let self = self else { return }
            self.loading = callState != .inCall
        }
        .store(in: &cancellables)
    }
    
}
