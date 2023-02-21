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
    
    @Published var hasPermissionsToSpeak = false
    @Published var isUserMuted = true
    @Published var loading = true
    @Published var permissionPopupShown = false
    @Published var revokePermissionPopupShown = false
    @Published var activeCallPermissions = [String: [String]]() {
        didSet {
            hasPermissionsToSpeak = activeCallPermissions[streamVideo.user.id]?.contains("send-audio") == true
                || isCurrentUserHost
        }
    }
    var revokingParticipant: CallParticipant? {
        didSet {
            if revokingParticipant != nil {
                revokePermissionPopupShown = true
            }
        }
    }
    
    var permissionRequest: PermissionRequest? {
        didSet {
            permissionPopupShown = permissionRequest != nil
        }
    }
    
    private let audioRoom: AudioRoom
    private var cancellables = Set<AnyCancellable>()
    private var permissionsController: PermissionsController!
    private let callType = "livestream"
    
    init(audioRoom: AudioRoom) {
        self.audioRoom = audioRoom
        self.permissionsController = streamVideo.makePermissionsController()
        checkAudioSettings()
        callViewModel.startCall(
            callId: audioRoom.id,
            type: callType,
            participants: audioRoom.hosts
        )
        subscribeForParticipantChanges()
        subscribeForAudioChanges()
        subscribeForCallStateChanges()
        subscribeForAudioChanges()
        subscribeForPermissionsRequests()
        subscribeForPermissionUpdates()
    }
    
    func leaveCall() {
        callViewModel.hangUp()
    }
    
    func raiseHand() {
        Task {
            try await permissionsController.request(
                permissions: [.sendAudio],
                callId: audioRoom.id,
                callType: callType
            )
        }
    }
    
    func grantUserPermissions() {
        guard let permissionRequest else { return }
        var callId = ""
        var callType = ""
        let idComponents = permissionRequest.callCid.components(separatedBy: ":")
        if idComponents.count >= 2  {
            callId = idComponents[1]
            callType = idComponents[0]
        } else {
            return
        }
        Task {
            try await permissionsController.grant(
                permissions: permissionRequest.permissions.compactMap { Permission(rawValue: $0) },
                for: permissionRequest.user.id,
                callId: callId,
                callType: callType
            )
        }
    }
    
    func revokePermissions() {
        guard let revokingParticipant else { return }
        Task {
            try await permissionsController.revoke(
                permissions: [.sendAudio],
                for: revokingParticipant.userId,
                callId: audioRoom.id,
                callType: callType
            )
        }
    }
    
    func canAskForAudioPermission() -> Bool {
        permissionsController.currentUserCanRequestPermissions([.sendAudio])
    }
    
    func changeMuteState() {
        callViewModel.toggleMicrophoneEnabled()
    }
    
    private func checkAudioSettings() {
        hasPermissionsToSpeak = isCurrentUserHost
        isUserMuted = !isCurrentUserHost
        callViewModel.callSettings = CallSettings(audioOn: isCurrentUserHost, videoOn: false)
    }
    
    private var isCurrentUserHost: Bool {
        let hostIds = self.audioRoom.hosts.map { $0.id }
        let isCurrentUserHost = hostIds.contains(streamVideo.user.id)
        return isCurrentUserHost
    }
    
    private func subscribeForParticipantChanges() {
        callViewModel.$callParticipants.sink { [weak self] participants in
            guard let self = self else { return }
            self.update(participants: participants)
        }
        .store(in: &cancellables)
    }
    
    private func update(participants: [String: CallParticipant]) {
        var hostIds = self.audioRoom.hosts.map { $0.id }
        self.hosts = participants.filter { (key, participant) in
            hostIds.contains(participant.userId)
        }
        .map { $0.value }
        .sorted(by: { $0.name < $1.name })
        
        for (userId, capabilities) in activeCallPermissions {
            if capabilities.contains("send-audio"),
                let participant = findUser(with: userId, in: participants) {
                hosts.append(participant)
                hostIds.append(userId)
            }
        }
        
        self.otherUsers = participants.filter { (key, participant) in
            !hostIds.contains(participant.userId)
        }
        .map { $0.value }
        .sorted(by: { $0.name < $1.name })
    }
    
    private func findUser(
        with userId: String,
        in participants: [String: CallParticipant]
    ) -> CallParticipant? {
        for (_, participant) in participants {
            if participant.userId == userId {
                return participant
            }
        }
        return nil
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
    
    private func subscribeForPermissionsRequests() {
        Task {
            for await request in permissionsController.permissionRequests() {
                self.permissionRequest = request
            }
        }
    }
    
    private func subscribeForPermissionUpdates() {
        Task {
            for await update in permissionsController.permissionUpdates() {
                let userId = update.user.id
                self.activeCallPermissions[userId] = update.ownCapabilities
                if userId == streamVideo.user.id
                    && !update.ownCapabilities.contains("send-audio")
                    && callViewModel.callSettings.audioOn {
                    changeMuteState()
                }
                self.update(participants: callViewModel.callParticipants)
            }
        }
    }
    
}
